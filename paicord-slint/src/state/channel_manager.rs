use std::{
    collections::{HashMap, VecDeque},
    rc::Rc,
};

use anyhow::bail;
use paicord_rs::{
    discord_models::types::{
        channel::DiscordChannel,
        gateway::{GatewayEvent, GatewayPayload, GuildMembersChunkPayload, PartialMessage},
        guild::{Guild, PartialMember},
        permission::Role,
        snowflake::Snowflake,
        user::PartialUser,
    },
    markdown::DiscordMarkdownParser,
};
use slint::{ComponentHandle, Model, ModelRc, Weak};
use tokio::sync::mpsc;

use crate::{
    app::{ChannelStore, DiscordMessageSlint, MainWindow, PaicordCommand},
    images::ImageMangler,
    models::{channel_list_model::ChannelListModel, message_list_model::MessageListModel},
    state::PaicordManager,
    utils,
};

pub struct ChannelManager {
    command_sender: mpsc::Sender<PaicordCommand>,
    ui: Weak<MainWindow>,

    channels: HashMap<Snowflake, DiscordChannel>,
    current_channel: Option<DiscordChannel>,

    message_queue_sender: mpsc::Sender<DiscordMessageSlint>,
    messages: VecDeque<PartialMessage>,

    markdown_parser: DiscordMarkdownParser,

    current_guild_id: Option<Snowflake>,
}

impl ChannelManager {
    pub fn new(
        command_sender: mpsc::Sender<PaicordCommand>,
        ui: Weak<MainWindow>,
    ) -> anyhow::Result<Self> {
        let (message_queue_sender, mut message_queue_receiver) = mpsc::channel(64);
        let manager = Self {
            command_sender,
            ui,

            channels: HashMap::new(),
            current_channel: None,

            message_queue_sender,
            messages: VecDeque::new(),
            markdown_parser: DiscordMarkdownParser::new(),
            current_guild_id: None,
        };

        let command_sender = manager.command_sender.clone();

        manager.ui.upgrade_in_event_loop(move |ui| {
            let channel_store = ui.global::<ChannelStore>();
            let c1 = command_sender.clone();
            channel_store.on_select_channel(move |channel_id| {
                let _ = c1.try_send(PaicordCommand::SelectChannel(channel_id.to_string().into()));
            });

            let c2 = command_sender.clone();
            channel_store.on_send_message(move |content| {
                let _ = c2.try_send(PaicordCommand::RequestSendMessage(content.to_string()));
            });
        })?;

        let ui = manager.ui.clone();

        tokio::spawn(async move {
            while let Some(message) = message_queue_receiver.recv().await {
                ui.upgrade_in_event_loop(move |ui| {
                    let store = ui.global::<ChannelStore>();
                    let messages = store.get_messages();
                    messages.set_row_data(0, message);
                })
                .unwrap();
            }
        });

        Ok(manager)
    }

    async fn populate(
        &mut self,
        guild: &Guild,
        image_mangler: &ImageMangler,
    ) -> anyhow::Result<()> {
        self.channels.clear();
        self.messages.clear();
        self.current_guild_id = Some(guild.id);

        for channel in &guild.channels {
            self.channels.insert(channel.id, channel.clone());
        }

        let model = ChannelListModel::new(guild, image_mangler)?;

        self.ui.upgrade_in_event_loop(move |ui| {
            ui.global::<ChannelStore>()
                .set_channels(ModelRc::new(Rc::new(model)));
        })?;

        Ok(())
    }

    fn handle_select_channel(&mut self, channel_id: Snowflake) -> anyhow::Result<()> {
        if let Some(channel) = self.channels.get(&channel_id) {
            self.current_channel = Some(channel.clone());
            let _ = self
                .command_sender
                .try_send(PaicordCommand::ChannelSelected(channel.clone()));
        }

        Ok(())
    }

    async fn add_message(
        &mut self,
        partial_message: &PartialMessage,
        guild_member: &Option<PartialMember>,
        referenced_member: &Option<PartialMember>,
        guild_roles: &Vec<Role>,
        guild_id: &Option<Snowflake>,
    ) -> anyhow::Result<()> {
        let Some(current_channel) = &self.current_channel else {
            return Ok(());
        };

        if partial_message.channel_id != current_channel.id {
            return Ok(());
        }

        if let Some(message) = self
            .messages
            .iter_mut()
            .find(|m| m.id == partial_message.id)
        {
            *message = partial_message.clone();
        } else {
            self.messages.push_back(partial_message.clone());
        }

        if self.messages.len() > 200 {
            self.messages.pop_front();
        }

        let mut slint_message = DiscordMessageSlint::from_partial(
            &partial_message,
            guild_member.as_ref(),
            referenced_member.as_ref(),
            guild_id.as_ref(),
            &self.markdown_parser,
        )
        .await?;

        let author_color = utils::get_message_color(partial_message, guild_member, guild_roles);

        slint_message.author.has_role_color = author_color.is_some();
        slint_message.author.role_color =
            utils::discord_color_to_slint(author_color.unwrap_or_default());

        if let Some(referenced_message) = &partial_message.referenced_message {
            let referenced_color =
                utils::get_message_color(referenced_message, referenced_member, guild_roles);
            slint_message.referenced_message.author.has_role_color = referenced_color.is_some();
            slint_message.referenced_message.author.role_color =
                utils::discord_color_to_slint(referenced_color.unwrap_or_default());
        }

        self.message_queue_sender.try_send(slint_message)?;

        Ok(())
    }

    async fn handle_list_messages(
        &mut self,
        messages: &Vec<PartialMessage>,
        image_mangler: &ImageMangler,
    ) -> anyhow::Result<()> {
        let Some(current_channel) = &self.current_channel else {
            bail!("No channel selected");
        };

        for message in messages {
            if message.channel_id != current_channel.id {
                continue;
            }
            self.messages.push_back(message.clone());
        }

        let message_list_model = MessageListModel::new(
            messages,
            current_channel.guild_id.as_ref(),
            &self.markdown_parser,
            image_mangler,
        )
        .await?;

        self.ui.upgrade_in_event_loop(move |ui| {
            let channel_store = ui.global::<ChannelStore>();
            channel_store.set_messages(ModelRc::new(Rc::new(message_list_model)));
        })?;

        let Some(guild_id) = self.current_guild_id else {
            return Ok(());
        };

        self.command_sender
            .try_send(PaicordCommand::RequestGuildMembersChunk {
                guild_id,
                user_ids: messages
                    .iter()
                    .filter_map(|m| m.author.as_ref().map(|author| author.id))
                    .collect(),
            })?;

        Ok(())
    }

    async fn handle_guild_members_chunk(
        &mut self,
        members: &Vec<PartialMember>,
        guild_roles: &Vec<Role>,
        guild_id: &Option<Snowflake>,
    ) -> anyhow::Result<()> {
        let messages = self.messages.clone();

        for member in members {
            let Some(user) = &member.user else {
                continue;
            };

            for message in messages
                .iter()
                .filter(|m| m.author.as_ref().map(|a| a.id) == Some(user.id))
            {
                let referenced_member =
                    if let Some(referenced_message) = &message.referenced_message {
                        if let Some(referenced_user) = &referenced_message.author {
                            members
                                .iter()
                                .find(|m| m.user.as_ref().map(|u| u.id) == Some(referenced_user.id))
                        } else {
                            None
                        }
                    } else {
                        None
                    };

                self.add_message(
                    message,
                    &Some(member.clone()),
                    &referenced_member.cloned(),
                    guild_roles,
                    guild_id,
                )
                .await?;
            }
        }

        Ok(())
    }

    async fn handle_gateway_event(&mut self, event: &GatewayEvent) -> anyhow::Result<()> {
        let Some(data) = &event.data else {
            return Ok(());
        };

        match data {
            _ => {}
        }

        Ok(())
    }

    async fn handle_request_send_message(&mut self, content: &String) -> anyhow::Result<()> {
        let Some(current_channel) = &self.current_channel else {
            return Ok(());
        };

        self.command_sender.try_send(PaicordCommand::SendMessage {
            channel: current_channel.id,
            content: content.to_owned(),
        })?;

        Ok(())
    }
}

impl PaicordManager for ChannelManager {
    async fn handle_command(
        &mut self,
        command: &PaicordCommand,
        image_mangler: &ImageMangler,
    ) -> anyhow::Result<()> {
        match command {
            PaicordCommand::GuildSelected(guild) => {
                self.populate(guild, image_mangler).await?;
            }

            PaicordCommand::SelectChannel(channel_id) => {
                self.handle_select_channel(channel_id.clone())?;
            }

            PaicordCommand::ListMessages(messages) => {
                self.handle_list_messages(messages, image_mangler).await?;
            }

            PaicordCommand::GatewayEvent(event) => {
                self.handle_gateway_event(event).await?;
            }

            PaicordCommand::MessageCreated {
                partial_message,
                stored_member,
                referenced_member,
                guild_roles,
                guild_id
            } => {
                self.add_message(
                    partial_message,
                    stored_member,
                    referenced_member,
                    guild_roles,
                    guild_id,
                )
                .await?;
            }

            PaicordCommand::GuildMembersChunk {
                members,
                guild_roles,
                guild_id,
            } => {
                self.handle_guild_members_chunk(members, guild_roles, guild_id)
                    .await?;
            }

            PaicordCommand::RequestSendMessage(content) => {
                self.handle_request_send_message(content).await?;
            }
            _ => {}
        }
        Ok(())
    }
}
