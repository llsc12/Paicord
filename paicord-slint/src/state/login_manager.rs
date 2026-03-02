use std::error::Error;

use anyhow::{anyhow, bail};
use directories::ProjectDirs;
use paicord_rs::{
    discord_gateway::remote_auth_gateway_manager::{RemoteAuthGatewayManager, RemoteAuthOpcode},
    discord_http::endpoints::cdn_endpoints::{self, CDNEndpoint},
    discord_models::types::user::PartialUser,
};
use persistent_kv::{Config, PersistentKeyValueStore};
use qrcode_generator::QrCodeEcc;
use slint::{ComponentHandle, ToSharedString, Weak};
use tokio::sync::mpsc;

use crate::{
    app::{LoginManagerSlint, MainWindow, PaicordCommand, PartialUserSlint},
    images::ImageMangler,
    state::gateway_manager::GatewayManager,
};

pub struct LoginManager {
    remote_auth_gateway_manager: RemoteAuthGatewayManager,

    command_sender: mpsc::Sender<PaicordCommand>,
    ui: Weak<MainWindow>,

    fingerprint: Option<String>,
}

impl LoginManager {
    pub fn new(
        command_sender: mpsc::Sender<PaicordCommand>,
        ui: Weak<MainWindow>,
    ) -> anyhow::Result<Self> {
        let s = command_sender.clone();
        ui.upgrade_in_event_loop(move |ui| {
            let login_manager_slint = ui.global::<LoginManagerSlint>();

            let s1 = s.clone();
            login_manager_slint.on_initialize(move || {
                let _ = s1.try_send(PaicordCommand::InitLogin);
            });

            let s2 = s.clone();
            login_manager_slint.on_login_token(move |token| {
                let _ = s2.try_send(PaicordCommand::GatewayLogin(token.to_string()));
            });
        })?;

        let login_manager = Self {
            remote_auth_gateway_manager: RemoteAuthGatewayManager::new(),
            fingerprint: None,
            command_sender,
            ui,
        };

        Ok(login_manager)
    }

    pub async fn initialize(
        &mut self,
        dirs: &ProjectDirs,
        gateway_manager: &GatewayManager,
    ) -> anyhow::Result<()> {
        self.fingerprint_setup(dirs, gateway_manager).await?;

        self.remote_auth_gateway_manager.connect().await;

        let command_sender = self.command_sender.clone();
        let manager = self.remote_auth_gateway_manager.clone();

        tokio::spawn(async move {
            loop {
                let event = manager.next_event().await;

                match event.op {
                    RemoteAuthOpcode::PendingRemoteInit => {
                        let Some(fingerprint) = event.fingerprint else {
                            manager.disconnect().await;
                            let _ = command_sender.try_send(PaicordCommand::Panic(
                                "No fingerprint received in PendingRemoteInit".to_string(),
                            ));
                            break;
                        };

                        let _ =
                            command_sender.try_send(PaicordCommand::PendingRemoteInit(fingerprint));
                    }

                    RemoteAuthOpcode::PendingTicket => {
                        let Some(user) = event.user_payload else {
                            manager.disconnect().await;
                            let _ = command_sender.try_send(PaicordCommand::Panic(
                                "No user payload received in PendingTicket".to_string(),
                            ));
                            break;
                        };

                        let _ = command_sender.try_send(PaicordCommand::PendingTicket(user.into()));
                    }

                    RemoteAuthOpcode::PendingLogin => {
                        let Some(ticket) = event.ticket else {
                            manager.disconnect().await;
                            let _ = command_sender.try_send(PaicordCommand::Panic(
                                "No ticket received in PendingLogin".to_string(),
                            ));
                            break;
                        };

                        let _ =
                            command_sender.try_send(PaicordCommand::PendingLogin(ticket.to_string()));
                    }
                    _ => {}
                }
            }
        });

        Ok(())
    }

    pub async fn disconnect(&mut self) -> anyhow::Result<()> {
        self.remote_auth_gateway_manager.disconnect().await;

        self.ui.upgrade_in_event_loop(move |ui| {
            let login_manager_slint = ui.global::<LoginManagerSlint>();
            login_manager_slint.set_raUser(PartialUserSlint::default());
            login_manager_slint.set_qrCode(slint::Image::default());
            login_manager_slint.set_remote_auth_fingerprint("".into());
        })?;

        Ok(())
    }

    async fn fingerprint_setup(
        &mut self,
        dirs: &ProjectDirs,
        gateway_manager: &GatewayManager,
    ) -> anyhow::Result<()> {
        let store: PersistentKeyValueStore<String, String> =
            PersistentKeyValueStore::new(dirs.data_dir(), Config::default())
                .map_err(|e| anyhow!(e))?;

        if let Some(fingerprint) = store.get("Authentication.Fingerprint") {
            self.fingerprint = Some(fingerprint);
            return Ok(());
        }

        self.fingerprint = gateway_manager
            .unauthenticated_client
            .get_fingerprint()
            .await;

        if let Some(ref fingerprint) = self.fingerprint {
            store
                .set("Authentication.Fingerprint", fingerprint)
                .map_err(|e| anyhow!(e))?;
        } else {
            self.command_sender.try_send(PaicordCommand::Panic(
                "Failed to retrieve fingerprint".to_string(),
            ))?;
        }

        Ok(())
    }

    pub fn pending_remote_init<S: AsRef<str>>(&mut self, fingerprint: S) -> anyhow::Result<()> {
        let fingerprint = fingerprint.as_ref().to_string();
        let url = format!("https://discord.com/ra/{}", fingerprint);
        let qr_code_svg =
            qrcode_generator::to_svg_to_string(url, QrCodeEcc::Low, 150, None::<&str>)?;

        self.ui.upgrade_in_event_loop(move |ui| {
            let image = slint::Image::load_from_svg_data(&qr_code_svg.into_bytes()).unwrap();
            let login_manager_slint = ui.global::<LoginManagerSlint>();
            login_manager_slint.set_qrCode(image);
            login_manager_slint.set_remote_auth_fingerprint(fingerprint.into());
        })?;

        Ok(())
    }

    pub async fn pending_ticket(
        &mut self,
        user: &PartialUser,
        image_mangler: &ImageMangler,
    ) -> anyhow::Result<()> {
        let user = user.clone();
        let username = user.username.unwrap_or("Unknown User".to_string());
        let global_name = user.global_name.unwrap_or_else(|| username.clone());
        let avatar_url = if let Some(avatar) = user.avatar {
            cdn_endpoints::get_cdn_url(CDNEndpoint::UserAvatar {
                user_id: user.id,
                avatar: avatar,
            })
        } else {
            "".to_string()
        };

        let image = image_mangler.get_buffer(avatar_url, 150, 150, true).await;

        self.ui.upgrade_in_event_loop(move |ui| {
            let login_manager_slint = ui.global::<LoginManagerSlint>();
            login_manager_slint.set_raUser(PartialUserSlint {
                id: "".into(),
                avatar: slint::Image::from_rgba8_premultiplied(image),
                global_name: global_name.into(),
                username: username.into(),
            });
        })?;

        Ok(())
    }

    pub async fn pending_login<S: AsRef<str>>(&mut self, ticket: S) -> anyhow::Result<()> {
        let ticket = ticket.as_ref().to_string();
        //TODO: switch paicord-rs to anyhow errors
        let Ok(token) = self.remote_auth_gateway_manager.exchange_default(ticket).await else {
            bail!("Failed to exchange ticket for token");
        };

        println!("Received token: {}", token);

        let _ = self.command_sender.try_send(PaicordCommand::GatewayLogin(token));

        Ok(())
    }
}
