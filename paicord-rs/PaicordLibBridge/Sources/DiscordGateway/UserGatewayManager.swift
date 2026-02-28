import Logging
import PaicordLib

func user_gateway_manager_new(token: RustString) async -> UserGatewayManager {
    return await UserGatewayManager(token: Secret(token.toString()))
}

extension UserGatewayManager {
    func next_event() async -> GatewayEventRust {
        for await event in await self.events {
            var data: GatewayPayloadRust? = nil
            switch event.data {
            case .ready(let ready):
                data = GatewayPayloadRust.Ready(ReadyPayloadRust(ready: ready))
            default:
                data = nil
            }

            return GatewayEventRust(data: data)
        }

        fatalError("Event loop stopped unexpectedly")
    }
}
