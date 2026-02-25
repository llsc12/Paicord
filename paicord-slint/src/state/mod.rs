use std::error::Error;

use slint::Weak;
use tokio::sync::mpsc;

use crate::{app::{MainWindow, PaicordCommand}, state::login_manager::LoginManager};

pub mod login_manager;

pub struct AppState {
    login_manager: LoginManager,

    ui: Weak<MainWindow>,
    command_sender: mpsc::Sender<PaicordCommand>
}

impl AppState {
    pub fn new(sender: mpsc::Sender<PaicordCommand>, ui: Weak<MainWindow>) -> Result<Self, Box<dyn Error>> {
        let state = Self {
            login_manager: LoginManager::new(sender.clone(), ui.clone())?,
            
            ui,
            command_sender: sender,
        };

        Ok(state)
    }

    pub async fn handle_command(&mut self, command: &PaicordCommand) -> Result<(), Box<dyn Error>> {
        Ok(())
    } 
}