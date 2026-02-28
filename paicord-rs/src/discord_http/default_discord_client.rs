use std::sync::Arc;
use crate::ffi;

#[derive(Clone)]
pub struct DefaultDiscordClient {
    inner: Arc<ffi::BridgedDefaultDiscordClient>
}

impl DefaultDiscordClient {
    pub fn new() -> Self {
        Self {
            inner: Arc::new(ffi::default_discord_client_new()),
        }
    }

    pub async fn get_fingerprint(&self) -> Option<String> {
        self.inner.get_fingerprint().await
    }
}

unsafe impl Send for DefaultDiscordClient {}
unsafe impl Sync for DefaultDiscordClient {}

unsafe impl Send for ffi::BridgedDefaultDiscordClient {}
unsafe impl Sync for ffi::BridgedDefaultDiscordClient {}