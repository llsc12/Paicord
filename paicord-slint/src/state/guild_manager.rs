use std::{collections::HashMap, rc::Rc};

use paicord_rs::{
    discord_http::endpoints::cdn_endpoints::{self, CDNEndpoint},
    discord_models::{
        protobuf::preloaded_user_settings::{GuildFolder, GuildFolders},
        types::{
            gateway::{
                GatewayEvent, GatewayPayload, GuildMembersChunkPayload, MessageCreatePayload,
                ReadyPayload,
            },
            guild::{Guild, PartialMember},
            permission::Role,
            snowflake::Snowflake,
            user::PartialUser,
        },
    },
};
use slint::{ComponentHandle, ModelRc, Weak};
use tokio::sync::mpsc;

use crate::{
    app::{CurrentUserStore, GuildStore, MainWindow, PaicordCommand, PartialUserSlint},
    images::ImageMangler,
    models::guild_list_model::GuildListModel,
    state::PaicordManager,
    utils,
};

pub struct GuildManager {
    command_sender: mpsc::Sender<PaicordCommand>,
    ui: Weak<MainWindow>,

    folders: Option<GuildFolders>,
    guilds: HashMap<Snowflake, Guild>,
    members: HashMap<Snowflake, PartialMember>,
    current_guild_id: Option<Snowflake>,
}

impl GuildManager {
    pub fn new(
        command_sender: mpsc::Sender<PaicordCommand>,
        ui: Weak<MainWindow>,
    ) -> anyhow::Result<Self> {
        let manager = Self {
            command_sender,
            ui,

            folders: None,
            guilds: HashMap::new(),
            members: HashMap::new(),
            current_guild_id: None,
        };

        let command_sender = manager.command_sender.clone();

        manager.ui.upgrade_in_event_loop(move |ui| {
            ui.global::<GuildStore>().on_select_guild(move |guild_id| {
                let guild_id = Snowflake::from(guild_id.to_string());
                let _ = command_sender.try_send(PaicordCommand::SelectGuild(guild_id));
            });
        })?;

        Ok(manager)
    }

    async fn handle_event(
        &mut self,
        event: &GatewayEvent,
        image_mangler: &ImageMangler,
    ) -> anyhow::Result<()> {
        let Some(data) = &event.data else {
            return Ok(());
        };

        match data {
            GatewayPayload::Ready(ready) => {
                self.handle_ready(ready, image_mangler).await?;
            }
            GatewayPayload::GuildMembersChunk(chunk) => {
                self.handle_guild_members_chunk(chunk)?;
            }
            GatewayPayload::MessageCreate(message) => {
                self.handle_message_create(message)?;
            }
            _ => {}
        }

        Ok(())
    }

    fn handle_message_create(&mut self, payload: &MessageCreatePayload) -> anyhow::Result<()> {
        let partial_message = payload.to_partial_message();
        let member_id = utils::fetch_user_id(
            partial_message.clone().member,
            partial_message.author.as_ref().map(PartialUser::from),
        );

        let member = member_id.and_then(|id| self.members.get(&id)).cloned();

        let mut guild_roles = Vec::new();
        if let Some(guild_id) = self.current_guild_id && let Some(guild) = self.guilds.get(&guild_id) {
            guild_roles = guild.get_roles().clone();
        }
        self.command_sender
            .try_send(PaicordCommand::MessageCreated {
                partial_message,
                stored_member: member,
                guild_roles,
            })?;

        Ok(())
    }

    async fn handle_ready(
        &mut self,
        ready: &ReadyPayload,
        image_mangler: &ImageMangler,
    ) -> anyhow::Result<()> {
        if let Some(user_settings_proto) = &ready.user_settings_proto {
            self.folders = Some(user_settings_proto.guild_folders.clone());
        }

        for guild in &ready.guilds {
            self.guilds.insert(guild.id, guild.clone());
        }

        let model = GuildListModel::new(self.guilds.clone(), self.folders.clone(), &image_mangler)?;

        self.ui.upgrade_in_event_loop(move |ui| {
            let model = ModelRc::new(Rc::new(model));
            let guild_store = ui.global::<GuildStore>();
            guild_store.set_guild_folders(model);
        })?;

        Ok(())
    }

    fn handle_guild_members_chunk(
        &mut self,
        chunk: &GuildMembersChunkPayload,
    ) -> anyhow::Result<()> {
        let Some(current_guild_id) = self.current_guild_id else {
            return Ok(());
        };

        let Some(guild) = self.guilds.get(&current_guild_id) else {
            return Ok(());
        };

        if chunk.guild_id != current_guild_id {
            return Ok(());
        }

        for member in &chunk.members {
            let Some(user) = &member.user else {
                continue;
            };

            self.members.insert(user.id, member.clone());
        }

        self.command_sender.try_send(PaicordCommand::GuildMembersChunk { members: chunk.members.clone(), guild_roles: guild.get_roles() })?;

        Ok(())
    }

    fn handle_select_guild(
        &mut self,
        guild_id: &Snowflake,
        image_mangler: &ImageMangler,
    ) -> anyhow::Result<()> {
        let Some(guild) = self.guilds.get(guild_id) else {
            return Ok(());
        };

        self.members.clear();
        for member in guild.get_members() {
            if let Some(user) = &member.user {
                self.members.insert(user.id, member.clone());
            }
        }

        self.command_sender
            .try_send(PaicordCommand::GuildSelected(guild.clone()))?;

        self.current_guild_id = Some(guild.id);

        let has_banner = guild.banner.is_some();

        self.ui.upgrade_in_event_loop(move |ui| {
            let guild_store = ui.global::<GuildStore>();
            guild_store.set_has_banner(has_banner);
        })?;

        let Some(banner_url) = guild.banner.as_ref() else {
            return Ok(());
        };

        let banner_url = cdn_endpoints::get_cdn_url(CDNEndpoint::GuildBanner {
            guild_id: guild.id,
            banner: banner_url.clone(),
        });

        let banner_buffer =
            image_mangler.lazy_get_buffer(banner_url, 568, 319, true, move |ui, image| {
                let guild_store = ui.global::<GuildStore>();
                guild_store.set_banner(image);
            });

        self.ui.upgrade_in_event_loop(move |ui| {
            let guild_store = ui.global::<GuildStore>();
            guild_store.set_banner(slint::Image::from_rgba8_premultiplied(banner_buffer));
        })?;

        Ok(())
    }
}

impl PaicordManager for GuildManager {
    async fn handle_command(
        &mut self,
        command: &PaicordCommand,
        image_mangler: &ImageMangler,
    ) -> anyhow::Result<()> {
        match command {
            PaicordCommand::GatewayEvent(event) => {
                self.handle_event(event, image_mangler).await?;
            }

            PaicordCommand::SelectGuild(guild_id) => {
                self.handle_select_guild(guild_id, image_mangler)?;
            }

            _ => {}
        }

        Ok(())
    }
}
