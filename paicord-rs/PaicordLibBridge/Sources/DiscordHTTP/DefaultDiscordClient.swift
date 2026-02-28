import PaicordLib

class BridgedDefaultDiscordClient {
    var inner: DefaultDiscordClient

    init(inner: DefaultDiscordClient) {
        self.inner = inner
    }

    func get_fingerprint() async -> Optional<String> {
        do {
            let request = try await self.inner.getExperiments()
            try request.guardSuccess()
            let data = try request.decode()
            return data.fingerprint
        } catch {
            return nil
        }
    }
}

func default_discord_client_new() -> BridgedDefaultDiscordClient {
    return BridgedDefaultDiscordClient(
        inner: DefaultDiscordClient(
            captchaCallback: nil,
            mfaCallback: nil
        ))
}