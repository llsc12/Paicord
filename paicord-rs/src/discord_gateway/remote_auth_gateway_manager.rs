use std::{error::Error, sync::Arc};

pub use ffi::{RemoteAuthOpcodeRust as RemoteAuthOpcode, RemoteAuthPayloadRust as RemoteAuthpayload };

#[swift_bridge::bridge]
mod ffi {
    enum RemoteAuthGatewayError {
        BridgedError(String)
    }

    pub enum RemoteAuthOpcodeRust {
        Hello,
        Init,
        Heartbeat,
        HeartbeatAck,
        NonceProof,
        PendingRemoteInit,
        PendingTicket,
        PendingLogin,
        Cancel,
    }

    #[swift_bridge(swift_repr = "struct")]
    struct UserPayloadRust {
        id: String,
        discriminator: String,
        avatar: Option<String>,
        username: String,
    }

    #[swift_bridge(swift_repr = "struct")]
    struct RemoteAuthPayloadRust {
        op: RemoteAuthOpcodeRust,
        heartbeat_interval: Option<i32>,
        timeout_ms: Option<i32>,
        encoded_public_key: Option<String>,
        encrypted_nonce: Option<String>,
        nonce: Option<String>,
        fingerprint: Option<String>,
        encrypted_user_payload: Option<String>,
        user_payload: Option<UserPayloadRust>,
        ticket: Option<String>
    }

    extern "Swift" {
        type RemoteAuthGatewayManager;
        fn remote_auth_gateway_manager_new() -> RemoteAuthGatewayManager;
        async fn connect(self: &RemoteAuthGatewayManager);
        async fn disconnect(self: &RemoteAuthGatewayManager);
        async fn next_event(self: &RemoteAuthGatewayManager) -> RemoteAuthPayloadRust;
        async fn exchange_default(self: &RemoteAuthGatewayManager, ticket: String) -> Result<String, RemoteAuthGatewayError>;
    }
}

#[derive(Clone)]
pub struct RemoteAuthGatewayManager {
    inner: Arc<ffi::RemoteAuthGatewayManager>
}

impl RemoteAuthGatewayManager {
    pub fn new() -> Self {
        Self {
            inner: Arc::new(ffi::remote_auth_gateway_manager_new())
        }
    }

    pub async fn connect(&self) {
        self.inner.connect().await;
    }

    pub async fn disconnect(&self) {
        self.inner.disconnect().await;
    }

    pub async fn next_event(&self) -> RemoteAuthpayload {
        self.inner.next_event().await
    }

    pub async fn exchange_default<S: AsRef<str>>(&self, ticket: S) -> Result<String, Box<dyn Error>> {
        let ticket = ticket.as_ref().to_string();
        self.inner.exchange_default(ticket).await.map_err(|e| match e {
            ffi::RemoteAuthGatewayError::BridgedError(message) => {
                message.into()
            }
        })
    }
}

unsafe impl Send for ffi::RemoteAuthGatewayManager {}
unsafe impl Sync for ffi::RemoteAuthGatewayManager {}