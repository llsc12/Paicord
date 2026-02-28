use std::sync::Arc;
use crate::ffi;

use crate::discord_models::types::gateway::GatewayEvent;

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

    pub async fn next_event(&self) -> GatewayEvent {
        self.inner.next_event().await
    }
}

unsafe impl Send for ffi::UserGatewayManager {}
unsafe impl Sync for ffi::UserGatewayManager {}