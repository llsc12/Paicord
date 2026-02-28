use std::error::Error;

use directories::ProjectDirs;
use slint::{ComponentHandle, ToSharedString, Weak};
use tokio::sync::mpsc;

use crate::{app::{AppStateSlint, MainWindow, PaicordCommand}, images::ImageMangler, state::{gateway_manager::GatewayManager, login_manager::LoginManager}};

pub mod login_manager;
pub mod gateway_manager;

pub struct AppState {
    login_manager: LoginManager,
    gateway_manager: GatewayManager,
    image_mangler: ImageMangler,
    project_dirs: ProjectDirs,

    ui: Weak<MainWindow>,
    command_sender: mpsc::Sender<PaicordCommand>
}

impl AppState {
    pub fn new(sender: mpsc::Sender<PaicordCommand>, ui: Weak<MainWindow>) -> anyhow::Result<Self> {
        let paths = directories::ProjectDirs::from("com", "rinlovesyou", "paicord").unwrap();
        let state = Self {
            login_manager: LoginManager::new(sender.clone(), ui.clone())?,
            gateway_manager: GatewayManager::new(sender.clone(), ui.clone())?,

            image_mangler: ImageMangler::new(ui.clone(), paths.cache_dir()),

            project_dirs: paths,
            command_sender: sender,
            ui,
        };

        state.ui.upgrade_in_event_loop(move |ui| {
            let app_state = ui.global::<AppStateSlint>();
            app_state.set_ready(true);
        })?;

        Ok(state)
    }

    pub async fn handle_command(&mut self, command: &PaicordCommand) -> anyhow::Result<()> {
        match command {
            //Login
            PaicordCommand::InitLogin => {
                self.login_manager.initialize(&self.project_dirs, &self.gateway_manager).await?;
            }

            PaicordCommand::PendingRemoteInit(fingerprint) => {
                self.login_manager.pending_remote_init(fingerprint)?;
            }

            PaicordCommand::PendingTicket(user) => {
                self.login_manager.pending_ticket(user, &self.image_mangler).await?;
            }

            PaicordCommand::PendingLogin(token) => {
                self.login_manager.pending_login(token).await?;
            }

            PaicordCommand::RemoteAuthFinish => {
                self.login_manager.disconnect().await?;
            }

            //Gateway
            PaicordCommand::GatewayLogin(token) => {
                self.gateway_manager.login(token).await?;
            }

            PaicordCommand::GatewayEvent(event) => {
                self.gateway_manager.handle_event(event).await?;
            }

            PaicordCommand::Panic(msg) => {
                let msg = msg.clone();
                self.ui.upgrade_in_event_loop(move |ui| {
                    ui.window().dispatch_event(slint::platform::WindowEvent::CloseRequested);
                })?;
                println!("Panic: {}", msg);
            }
            _ => {}
        }
        Ok(())
    } 
}