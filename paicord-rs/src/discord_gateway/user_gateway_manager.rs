use std::sync::Arc;

#[swift_bridge::bridge]
mod ffi {
    extern "Swift" {
        type UserGatewayManager;
        async fn user_gateway_manager_new(token: String) -> UserGatewayManager;
        async fn connect(self: &UserGatewayManager);
        async fn next_event(self: &UserGatewayManager) -> String;
    }
}

#[derive(Clone)]
pub struct UserGatewayManager {
    inner: Arc<ffi::UserGatewayManager>,
}

impl UserGatewayManager {
    pub async fn new(token: String) -> Self {
        let manager = ffi::user_gateway_manager_new(token).await;
        Self {
            inner: Arc::new(manager),
        }
    }

    pub async fn connect(&self) {
        self.inner.connect().await;
    }

    pub async fn next_event(&self) -> String {
        self.inner.next_event().await
    }
}

#[cfg(test)]
mod tests {
    use core::panic;
    use std::time::Duration;

    static TOKEN: &'static str = include_str!("../test_token.txt");

    use super::ffi;

    #[tokio::test]
    async fn test_user_gateway_manager() {
        let manager = ffi::user_gateway_manager_new(TOKEN.to_string()).await;
        manager.connect().await;

        while let event = manager.next_event().await
            && !event.is_empty()
        {
            println!("Received event: {}", event);
        }

        panic!("Connection closed unexpectedly");
    }
}

unsafe impl Send for ffi::UserGatewayManager {}
unsafe impl Sync for ffi::UserGatewayManager {}