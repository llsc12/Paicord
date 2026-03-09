use std::{error::Error, sync::{Arc}};

use directories::ProjectDirs;
use paicord_rs::{discord_models::types::{channel::DiscordChannel, gateway::{GatewayEvent, PartialMessage}, guild::{Guild, PartialMember}, permission::Role, snowflake::Snowflake, user::PartialUser}, markdown::DiscordMarkdownParser};
use tokio::sync::{RwLock, mpsc};

use crate::{state::AppState, utils};

pub type AppStatePtr = Arc<RwLock<AppState>>;

slint::include_modules!();

#[derive(Debug)]
pub enum PaicordCommand {
    // Login
    InitLogin,
    InitializeLoginManager(String),
    PendingRemoteInit(String),
    PendingTicket(PartialUser),
    PendingLogin(String),
    RemoteAuthCancel,
    RemoteAuthFinish,

    // Gateway
    GatewayLogin(String),
    GatewayEvent(GatewayEvent),
    SendMessage {
        channel: Snowflake,
        content: String,
    },

    //Guilds
    SelectGuild(Snowflake),
    GuildSelected(Guild),
    MessageCreated {
        partial_message: PartialMessage,
        stored_member: Option<PartialMember>,
        referenced_member: Option<PartialMember>,
        guild_roles: Vec<Role>,
        guild_id: Option<Snowflake>,
    },
    GuildMembersChunk {
        members: Vec<PartialMember>,
        guild_roles: Vec<Role>,
        guild_id: Option<Snowflake>,
    },
    
    //Channels
    SelectChannel(Snowflake),
    ChannelSelected(DiscordChannel),
    ListMessages(Vec<PartialMessage>),
    RequestGuildMembersChunk {
        guild_id: Snowflake,
        user_ids: Vec<Snowflake>,
    },
    RequestSendMessage(String),

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