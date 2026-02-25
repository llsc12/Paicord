import PaicordLib

func remote_auth_gateway_manager_new() -> RemoteAuthGatewayManager {
    return RemoteAuthGatewayManager()
}

extension RemoteAuthGatewayManager {
    func next_event() async -> RemoteAuthPayloadRust {
        for await event in self.events {
            let op =
                switch event.op {
                case .hello: RemoteAuthOpcodeRust.Hello
                case .`init`: RemoteAuthOpcodeRust.Init
                case .heartbeat: RemoteAuthOpcodeRust.Heartbeat
                case .heartbeat_ack: RemoteAuthOpcodeRust.HeartbeatAck
                case .nonce_proof: RemoteAuthOpcodeRust.NonceProof
                case .pending_remote_init: RemoteAuthOpcodeRust.PendingRemoteInit
                case .pending_ticket: RemoteAuthOpcodeRust.PendingTicket
                case .pending_login: RemoteAuthOpcodeRust.PendingLogin
                case .cancel: RemoteAuthOpcodeRust.Cancel
                }

            var user_payload: Optional<UserPayloadRust> = .none

            if let user_payload_swift = event.user_payload {
                user_payload = .some(
                    UserPayloadRust(
                        id: user_payload_swift.id.intoRustString(),
                        discriminator: user_payload_swift.discriminator.intoRustString(),
                        avatar: user_payload_swift.avatar?.intoRustString() ?? nil,
                        username: user_payload_swift.username.intoRustString()))
            }

            return RemoteAuthPayloadRust(
                op: op, heartbeat_interval: event.heartbeat_interval.map(Int32.init), timeout_ms: event.timeout_ms.map(Int32.init),
                encoded_public_key: event.encoded_public_key?.intoRustString() ?? nil,
                encrypted_nonce: event.encrypted_nonce?.intoRustString() ?? nil,
                nonce: event.nonce?.intoRustString() ?? nil,
                fingerprint: event.fingerprint?.intoRustString() ?? nil,
                encrypted_user_payload: event.encrypted_user_payload?.intoRustString() ?? nil,
                user_payload: user_payload, ticket: event.ticket?.intoRustString() ?? nil)
        }


        fatalError("Event loop stopped unexpectedly")
    }

    func exchange_default(ticket: RustString) async throws(RemoteAuthGatewayError) -> String {
        do {
            let token = try await self.exchange(
                ticket: ticket.toString(), client: DefaultDiscordClient())

            return token.value
        } catch {
            throw RemoteAuthGatewayError.BridgedError(error.localizedDescription.intoRustString())
        }
    }
}

extension RemoteAuthGatewayError: Error {}
extension RemoteAuthGatewayError: @unchecked Sendable {}
