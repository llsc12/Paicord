use std::error::Error;
use std::sync::Arc;
use crate::discord_models::types::snowflake::Snowflake;
use crate::ffi::{self, BridgedRustError, SnowflakeRust};

use crate::discord_models::types::gateway::{GatewayEvent, PartialMessage};

#[derive(Clone)]
pub struct UserGatewayManager {
    inner: Arc<ffi::UserGatewayManager>,
}

impl UserGatewayManager {
    pub async fn new<S: AsRef<str>>(token: S) -> Self {
        let manager = ffi::user_gateway_manager_new(token.as_ref().to_string()).await;
        Self {
            inner: Arc::new(manager),
        }
    }

    pub async fn connect(&self) {
        self.inner.connect().await;
    }

    pub async fn disconnect(&self) {
        self.inner.disconnect().await;
    }

    pub async fn update_guild_subscriptions(&self, id: Snowflake, typing: bool, activities: bool, threads: bool, member_updates: bool) {
        self.inner.update_guild_subscriptions(id, typing, activities, threads, member_updates).await;
    }

    pub async fn list_messages(&self, channel_id: Snowflake, limit: i32) -> Result<Vec<PartialMessage>, Box<dyn Error + Send + Sync>> {
        match self.inner.list_messages(channel_id, limit).await {
            Ok(bridged_vec) => {
                let mut messages = Vec::new();
                for i in 0..bridged_vec.len() {
                    let bridged_message = bridged_vec.get(i);
                    messages.push(PartialMessage::new(bridged_message));
                }
                Ok(messages)
            }
            Err(e) => match e {
                BridgedRustError::UnhandledError(e) => Err(Box::new(std::io::Error::new(std::io::ErrorKind::Other, e))),
            },
        }
    }

    pub async fn request_guild_members_chunk(&self, guild_id: SnowflakeRust, user_ids: &Vec<Snowflake>) {
        self.inner.request_guild_members_chunk(guild_id, user_ids.iter().map(|id| id.get_raw()).collect()).await;
    }

    pub async fn next_event(&self) -> GatewayEvent {
        let event = self.inner.next_event().await;
        GatewayEvent::new(event)
    }
}

unsafe impl Send for ffi::UserGatewayManager {}
unsafe impl Sync for ffi::UserGatewayManager {}