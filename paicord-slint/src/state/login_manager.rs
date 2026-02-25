use std::error::Error;

use paicord_rs::discord_gateway::remote_auth_gateway_manager::RemoteAuthGatewayManager;
use slint::Weak;
use tokio::sync::mpsc;

use crate::app::{MainWindow, PaicordCommand};

pub struct LoginManager {
    remote_auth_gateway_manager: RemoteAuthGatewayManager,

    command_sender: mpsc::Sender<PaicordCommand>,
    ui: Weak<MainWindow>,
}

impl LoginManager {
    pub fn new(command_sender: mpsc::Sender<PaicordCommand>, ui: Weak<MainWindow>) -> Result<Self, Box<dyn Error>> {
        let login_manager = Self {
            remote_auth_gateway_manager: RemoteAuthGatewayManager::new(),
            command_sender,
            ui
        };

        Ok(login_manager)
    }
}