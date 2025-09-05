import DiscordModels

public protocol DiscordClient: Sendable {
    /// Your app's id.
    /// If you don't provide it here, DiscordBM will try to extract it from your token.
    /// If there is no `appId` you will need to provide it at all call-sites of
    /// `DiscordClient` functions that accept an `appId`.
    var appId: ApplicationSnowflake? { get }

    /// Send a request to Discord with no body.
    func send(request: DiscordHTTPRequest) async throws -> DiscordHTTPResponse

    /// Send a request to payload with a JSON body.
    func send<E: Sendable & Encodable & ValidatablePayload>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordHTTPResponse

    /// Send a request to Discord with a Multipart body.
    func sendMultipart<E: Sendable & MultipartEncodable & ValidatablePayload>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordHTTPResponse
}

//MARK: - Default functions for DiscordClient
extension DiscordClient {

    /// Send a request to Discord with no body.
    @inlinable
    public func send<C: Codable>(request: DiscordHTTPRequest) async throws -> DiscordClientResponse<C> {
        let response = try await self.send(request: request)
        return DiscordClientResponse(httpResponse: response)
    }

    /// Send a request to Discord with no body and a file response.
    @inlinable
    public func send(
        request: DiscordHTTPRequest,
        fallbackFileName: String
    ) async throws -> DiscordCDNResponse {
        let response = try await self.send(request: request)
        return DiscordCDNResponse(httpResponse: response, fallbackFileName: fallbackFileName)
    }

    /// Send a request to payload with a JSON body.
    @inlinable
    public func send<E: Sendable & Encodable & ValidatablePayload, C: Codable>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordClientResponse<C> {
        let response = try await self.send(request: request, payload: payload)
        return DiscordClientResponse(httpResponse: response)
    }

    /// Send a request to Discord with a Multipart body.
    @inlinable
    public func sendMultipart<E: Sendable & MultipartEncodable & ValidatablePayload, C: Codable>(
        request: DiscordHTTPRequest,
        payload: E
    ) async throws -> DiscordClientResponse<C> {
        let response = try await self.sendMultipart(request: request, payload: payload)
        return DiscordClientResponse(httpResponse: response)
    }
}
