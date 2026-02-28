use std::{error::Error, sync::Arc};
use crate::ffi;

pub use ffi::RemoteAuthPayloadRust as RemoteAuthPayload;
pub use ffi::UserPayloadRust as UserPayload;
pub use ffi::RemoteAuthOpcodeRust as RemoteAuthOpcode;

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

    pub async fn next_event(&self) -> RemoteAuthPayload {
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