use std::error::Error;

use anyhow::bail;
use directories::ProjectDirs;
use paicord_rs::{discord_gateway::{remote_auth_gateway_manager::RemoteAuthGatewayManager, user_gateway_manager::UserGatewayManager}, discord_http::default_discord_client::DefaultDiscordClient, discord_models::types::gateway::GatewayEvent};
use persistent_kv::{Config, PersistentKeyValueStore};
use slint::{ComponentHandle, Weak};
use tokio::sync::mpsc;

use crate::app::{LoginManagerSlint, MainWindow, PaicordCommand};

pub struct GatewayManager {
    command_sender: mpsc::Sender<PaicordCommand>,
    ui: Weak<MainWindow>,

    pub unauthenticated_client: DefaultDiscordClient,
    user_gateway_manager: Option<UserGatewayManager>,
}

impl GatewayManager {
    pub fn new(command_sender: mpsc::Sender<PaicordCommand>, ui: Weak<MainWindow>) -> anyhow::Result<Self> {
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
            bail!("user_gateway_manager was None, this should be impossible");
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

    pub async fn handle_event(&mut self, _event: &GatewayEvent) -> anyhow::Result<()> {

        Ok(())
    }
}