import PaicordLib

extension GatewayPayloadRust? {
    init(payload: Gateway.Event.Payload) {
        switch payload {
            case .ready(let ready):
                self = .Ready(ReadyPayloadRust(ready: ready))
        
        default:
            self = nil
        }
    }
}

extension ReadyPayloadRust {
    init(ready: Gateway.Ready) {
        self.v = Int32(ready.v)
        self.user = DiscordUserRust(user: ready.user)
        self.session_id = ready.session_id.intoRustString()
        self.resume_gateway_url = ready.resume_gateway_url?.intoRustString() ?? nil
    }
}