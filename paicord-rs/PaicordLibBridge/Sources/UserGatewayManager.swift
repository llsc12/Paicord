import Logging
import PaicordLib

func user_gateway_manager_new(token: RustString) async -> UserGatewayManager {
    return await UserGatewayManager(token: Secret(token.toString()))
}

extension UserGatewayManager {
    func next_event() async -> String {
        for await event in await self.events {
            return event.type ?? "Unknown"
        }

        return ""
    }
}