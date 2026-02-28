use crate::ffi;
use crate::ffi::ReadyPayloadRust;

pub use ffi::GatewayEventRust as GatewayEvent;
pub use ffi::GatewayPayloadRust as GatewayPayload;

impl std::fmt::Debug for ReadyPayloadRust {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("ReadyPayloadRust")
            .field("v", &self.v)
            .field("user", &self.user)
            .field("session_id", &self.session_id)
            .field("resume_gateway_url", &self.resume_gateway_url)
            .finish()
    }
}

impl std::fmt::Debug for GatewayPayload {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Ready(arg0) => f.debug_tuple("Ready").field(arg0).finish(),
        }
    }
}

impl std::fmt::Debug for GatewayEvent {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("GatewayEventRust")
            .field("data", &self.data)
            .finish()
    }
}
