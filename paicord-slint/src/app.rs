use std::{error::Error, sync::{Arc}};

use paicord_rs::discord_models::types::{gateway::GatewayEvent, user::PartialUser};
use tokio::sync::{RwLock, mpsc};

use crate::state::AppState;

pub type AppStatePtr = Arc<RwLock<AppState>>;

slint::include_modules!();

#[derive(Clone, Debug)]
pub enum PaicordCommand {
    // Login
    InitLogin,
    PendingRemoteInit(String),
    PendingTicket(PartialUser),
    PendingLogin(String),
    RemoteAuthCancel,
    RemoteAuthFinish,

    // Gateway
    GatewayLogin(String),
    GatewayEvent(GatewayEvent),

    //Guilds
    SelectGuild(String),
    SelectChannel(String),
    SendMessage(String),

    Panic(String),
}

pub struct App {
    state: AppStatePtr,
    ui: MainWindow,
}

impl App {
    pub fn new() -> anyhow::Result<Self> {
        let (command_sender, mut command_receiver) = mpsc::channel(64);
        let main_window = MainWindow::new()?;

        let app = Self {
            state: Arc::new(RwLock::new(AppState::new(command_sender.clone(), main_window.as_weak())?)),
            ui: main_window
        };

        let app_state = app.state.clone();

        tokio::spawn(async move {
            while let Some(command) = command_receiver.recv().await {
                let mut app_state = app_state.write().await;
                
                if let Err(err) = app_state.handle_command(&command).await {
                    let msg = err.to_string();
                    let _ = app_state.handle_command(&PaicordCommand::Panic(msg)).await;
                }
            }
        });

        Ok(app)
    }

    pub fn run(&self) -> Result<(), slint::PlatformError> {
        self.ui.run()
    }
}