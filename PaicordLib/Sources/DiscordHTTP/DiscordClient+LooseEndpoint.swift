import enum NIOHTTP1.HTTPMethod

extension DiscordClient {
    /// Get a file from CDN using the raw url.
    /// This is useful to use with for example
    /// a `DiscordChannel.Message.Attachment` object's `url` property.
    @inlinable
    public func getFromCDN(url: String) async throws -> DiscordCDNResponse {
        let endpoint = LooseEndpoint(url: url)
        let fallbackName: String =
            url
            .split(separator: "/").last?
            .split(separator: ".").first
            .map { String($0) } ?? "unknown"
        return try await self.send(
            request: .init(to: endpoint),
            fallbackFileName: fallbackName
        )
    }
}
