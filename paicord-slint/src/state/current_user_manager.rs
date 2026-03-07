use paicord_rs::{discord_http::endpoints::cdn_endpoints::{self, CDNEndpoint}, discord_models::types::{gateway::{GatewayEvent, GatewayPayload, ReadyPayload}, user::PartialUser}};
use slint::{ComponentHandle, Weak};
use tokio::sync::mpsc;

use crate::{app::{CurrentUserStore, MainWindow, PaicordCommand, PartialUserSlint}, images::ImageMangler, state::PaicordManager};

pub struct CurrentUserManager {
    command_sender: mpsc::Sender<PaicordCommand>,
    ui: Weak<MainWindow>,

    current_user: Option<PartialUser>,
}

impl CurrentUserManager {
    pub fn new(command_sender: mpsc::Sender<PaicordCommand>, ui: Weak<MainWindow>) -> anyhow::Result<Self> {
        let manager = Self {
            command_sender,
            ui,
            current_user: None,
        };

        Ok(manager)
    }

    async fn set_current_user(&mut self, user: PartialUser, image_mangler: &ImageMangler) -> anyhow::Result<()> {
        self.current_user = Some(user.clone());

        let avatar_url = if let Some(avatar) = &user.avatar {
            cdn_endpoints::get_cdn_url(CDNEndpoint::UserAvatar {
                user_id: user.id,
                avatar: avatar.clone(),
            })
        } else {
            "".to_string()
        };

        let avatar_buffer = image_mangler.get_buffer(avatar_url, 128, 128, true).await;

        self.ui.upgrade_in_event_loop(move |ui| {
            let mut user = PartialUserSlint::from(user);
            user.avatar = slint::Image::from_rgba8_premultiplied(avatar_buffer);
            let current_user_store = ui.global::<CurrentUserStore>();
            current_user_store.set_current_user(user);
        })?;

        Ok(())
    }

    async fn handle_event(&mut self, event: &GatewayEvent, image_mangler: &ImageMangler) -> anyhow::Result<()> {
        let Some(data) = &event.data else {
            return Ok(());
        };

        match data {
            GatewayPayload::Ready(ready) => {
                self.handle_ready(ready, image_mangler).await?;
            }
            _ => {}
        }

        Ok(())
    }

    async fn handle_ready(&mut self, ready: &ReadyPayload, image_mangler: &ImageMangler) -> anyhow::Result<()> {
        self.set_current_user(ready.user.clone().into(), image_mangler).await?;
        Ok(())
    }
}

impl PaicordManager for CurrentUserManager {
    async fn handle_command(&mut self, command: &PaicordCommand, image_mangler: &ImageMangler) -> anyhow::Result<()> {
        match command {
            PaicordCommand::GatewayEvent(event) => {
                self.handle_event(event, image_mangler).await?;
            }
            _ => {}
        }

        Ok(())
    }
}
