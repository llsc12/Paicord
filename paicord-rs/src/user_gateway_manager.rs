#[swift_bridge::bridge]
mod ffi {
    extern "Swift" {
        #[swift_bridge(Sendable)]
        type UserGatewayManager;

        async fn user_gateway_manager_new(token: String) -> UserGatewayManager;

        async fn connect(self: &UserGatewayManager);
        async fn next_event(self: &UserGatewayManager) -> String;
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
