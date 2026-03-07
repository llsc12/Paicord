use std::error::Error;

use anyhow::bail;
use directories::ProjectDirs;
use paicord_rs::{
    discord_gateway::{
        remote_auth_gateway_manager::RemoteAuthGatewayManager,
        user_gateway_manager::UserGatewayManager,
    },
    discord_http::default_discord_client::DefaultDiscordClient,
    discord_models::types::{channel::DiscordChannel, gateway::GatewayEvent, guild::Guild, snowflake::Snowflake},
};
use persistent_kv::{Config, PersistentKeyValueStore};
use slint::{ComponentHandle, Weak};
use tokio::sync::mpsc;

use crate::{
    app::{LoginManagerSlint, MainWindow, PaicordCommand},
    state::PaicordManager,
};

pub struct GatewayManager {
    command_sender: mpsc::Sender<PaicordCommand>,
    ui: Weak<MainWindow>,

    pub unauthenticated_client: DefaultDiscordClient,
    user_gateway_manager: Option<UserGatewayManager>,
}

impl GatewayManager {
    pub fn new(
        command_sender: mpsc::Sender<PaicordCommand>,
        ui: Weak<MainWindow>,
    ) -> anyhow::Result<Self> {
        let gateway_manager = Self {
            command_sender,
            ui,

            unauthenticated_client: DefaultDiscordClient::new(),
            user_gateway_manager: None,
        };

        Ok(gateway_manager)
    }

    pub async fn login<S: AsRef<str>>(&mut self, token: S) -> anyhow::Result<()> {
        self.user_gateway_manager = Some(UserGatewayManager::new(token).await);
        let Some(user_gateway_manager) = &self.user_gateway_manager else {
            bail!("user_gateway_manager was None, this should be impossible in this case");
        };

        user_gateway_manager.connect().await;

        let gateway = user_gateway_manager.clone();
        let command_sender = self.command_sender.clone();

        command_sender.try_send(PaicordCommand::RemoteAuthFinish)?;

        tokio::spawn(async move {
            loop {
                let event = gateway.next_event().await;
                let _ = command_sender.try_send(PaicordCommand::GatewayEvent(event));
            }
        });

        Ok(())
    }

    async fn disconnect(&mut self) {
        let Some(user_gateway_manager) = &self.user_gateway_manager else {
            return;
        };

        user_gateway_manager.disconnect().await;
    }

    async fn handle_guild_selected(&mut self, guild: &Guild) {
        let Some(user_gateway_manager) = &self.user_gateway_manager else {
            return;
        };

        user_gateway_manager.update_guild_subscriptions(guild.id, true, false, true, true).await;
    }

    async fn handle_channel_selected(&mut self, channel: &DiscordChannel) -> anyhow::Result<()> {
        let Some(user_gateway_manager) = &self.user_gateway_manager else {
            return Ok(());
        };

        match user_gateway_manager.list_messages(channel.id, 50).await {
            Ok(mut messages) => {
                messages.reverse();
                self.command_sender.try_send(PaicordCommand::ListMessages(messages))?;
                Ok(())
            }
            Err(e) => {
                bail!("Failed to list messages for channel {}: {}", channel.id.get_description(), e);
            }
        }
    }

    async fn request_guild_members_chunk(&mut self, guild_id: &Snowflake, user_ids: &Vec<Snowflake>) {
        let Some(user_gateway_manager) = &self.user_gateway_manager else {
            return;
        };

        if user_ids.is_empty() {
            return;
        }

        println!("Requesting guild members chunks for guild {} with user count: {}", guild_id.get_description(), user_ids.len());

        user_gateway_manager.request_guild_members_chunk(guild_id.clone(), user_ids).await;
    }

    async fn handle_send_message(&mut self, channel: Snowflake, content: String) -> anyhow::Result<()> {
        let Some(user_gateway_manager) = &self.user_gateway_manager else {
            bail!("No user gateway manager available for sending message");
        };

        user_gateway_manager.send_message(channel, content).await;

        Ok(())
    }
}

impl PaicordManager for GatewayManager {
    async fn handle_command(
        &mut self,
        command: &PaicordCommand,
        _image_mangler: &crate::images::ImageMangler,
    ) -> anyhow::Result<()> {
        match command {
            PaicordCommand::InitLogin => {
                let Some(fingerprint) = self.unauthenticated_client.get_fingerprint().await else {
                    bail!("Failed to get fingerprint for login initialization");
                };
                self.command_sender.try_send(PaicordCommand::InitializeLoginManager(fingerprint))?;
            }
            PaicordCommand::GatewayLogin(token) => {
                self.login(token).await?;
            }

            PaicordCommand::GuildSelected(guild) => {
                self.handle_guild_selected(guild).await;
            }

            PaicordCommand::ChannelSelected(channel) => {
                self.handle_channel_selected(channel).await?;
            }

            PaicordCommand::RequestGuildMembersChunk { guild_id, user_ids } => {
                self.request_guild_members_chunk(guild_id, user_ids).await;
            }

            PaicordCommand::SendMessage { channel, content } => {
                self.handle_send_message(*channel, content.clone()).await?;
            }

            PaicordCommand::Panic(_) => {
                self.disconnect().await;
            }
            _ => {}
        }

        Ok(())
    }
}
