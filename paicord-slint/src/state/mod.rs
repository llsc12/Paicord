use std::error::Error;

use directories::ProjectDirs;
use paicord_rs::discord_models::types::gateway::GatewayEvent;
use slint::{ComponentHandle, ToSharedString, Weak};
use tokio::sync::mpsc;

use crate::{app::{AppStateSlint, MainWindow, PaicordCommand}, images::ImageMangler, state::{channel_manager::ChannelManager, current_user_manager::CurrentUserManager, gateway_manager::GatewayManager, guild_manager::GuildManager, login_manager::LoginManager}};

pub mod login_manager;
pub mod gateway_manager;
pub mod current_user_manager;
pub mod guild_manager;
pub mod channel_manager;

pub struct AppState {
    login_manager: LoginManager,
    gateway_manager: GatewayManager,
    current_user_manager: CurrentUserManager,
    guild_manager: GuildManager,
    channel_manager: ChannelManager,

    image_mangler: ImageMangler,
    project_dirs: ProjectDirs,
    

    ui: Weak<MainWindow>,
    command_sender: mpsc::Sender<PaicordCommand>
}

pub trait PaicordManager {
    #[allow(async_fn_in_trait)]
    async fn handle_command(&mut self, command: &PaicordCommand, image_mangler: &ImageMangler) -> anyhow::Result<()>;
}

impl AppState {
    pub fn new(sender: mpsc::Sender<PaicordCommand>, ui: Weak<MainWindow>) -> anyhow::Result<Self> {
        let paths = directories::ProjectDirs::from("com", "rinlovesyou", "paicord").unwrap();
        let state = Self {
            login_manager: LoginManager::new(sender.clone(), ui.clone(), paths.clone())?,
            gateway_manager: GatewayManager::new(sender.clone(), ui.clone())?,
            current_user_manager: CurrentUserManager::new(sender.clone(), ui.clone())?,
            guild_manager: GuildManager::new(sender.clone(), ui.clone())?,
            channel_manager: ChannelManager::new(sender.clone(), ui.clone())?,

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
        self.login_manager.handle_command(command, &self.image_mangler).await?;
        self.gateway_manager.handle_command(command, &self.image_mangler).await?;
        self.current_user_manager.handle_command(command, &self.image_mangler).await?;
        self.guild_manager.handle_command(command, &self.image_mangler).await?;
        self.channel_manager.handle_command(command, &self.image_mangler).await?;
        
        match command {
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