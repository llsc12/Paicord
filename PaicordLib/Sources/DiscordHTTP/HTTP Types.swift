@preconcurrency import AsyncHTTPClient
import DiscordModels
import Foundation
import NIOFoundationCompat
import NIOHTTP1

import struct NIOCore.ByteBuffer

public struct DiscordHTTPRequest: Sendable {
  /// The endpoint to send the request to.
  public let endpoint: AnyEndpoint
  /// The query parameters of the request.
  public let queries: [(String, String?)]
  /// The extra headers of the request.
  public let headers: HTTPHeaders

  public init(
    to endpoint: UserAPIEndpoint,
    queries: [(String, String?)] = [],
    headers: HTTPHeaders = [:]
  ) {
    self.endpoint = .userApi(endpoint)
    self.queries = queries
    self.headers = headers
  }

  public init(
    to endpoint: APIEndpoint,
    queries: [(String, String?)] = [],
    headers: HTTPHeaders = [:]
  ) {
    self.endpoint = .botApi(endpoint)
    self.queries = queries
    self.headers = headers
  }

  public init(
    to endpoint: CDNEndpoint,
    queries: [(String, String?)] = [],
    headers: HTTPHeaders = [:]
  ) {
    self.endpoint = .cdn(endpoint)
    self.queries = queries
    self.headers = headers
  }

  public init(to endpoint: LooseEndpoint) {
    self.endpoint = .loose(endpoint)
    self.queries = []
    self.headers = [:]
  }
}

/// Represents a raw Discord HTTP response.
public struct DiscordHTTPResponse: Sendable, CustomStringConvertible {
  let _response: HTTPClient.Response

  internal init(_response: HTTPClient.Response) {
    self._response = _response
  }

  public init(
    host: String,
    status: HTTPResponseStatus,
    version: HTTPVersion,
    headers: HTTPHeaders = [:],
    body: ByteBuffer? = nil
  ) {
    self._response = .init(
      host: host,
      status: status,
      version: version,
      headers: headers,
      body: body
    )
  }

  /// Remote host of the request.
  public var host: String {
    _response.host
  }
  /// Response HTTP status.
  public var status: HTTPResponseStatus {
    _response.status
  }
  /// Response HTTP version.
  public var version: HTTPVersion {
    _response.version
  }
  /// Response HTTP headers.
  public var headers: HTTPHeaders {
    _response.headers
  }
  /// Response body.
  public var body: ByteBuffer? {
    _response.body
  }

  public var description: String {
    "DiscordHTTPResponse("
      + "host: \(host), "
      + "status: \(status), "
      + "version: \(version), "
      + "headers: \(headers), "
      + "body: \(body.map({ String(buffer: $0) }) ?? "nil")"
      + ")"
  }

  /// Throws an error if the response does not indicate success.
  @inlinable
  public func guardSuccess() throws {
    guard (200..<300).contains(self.status.code) else {
      throw DiscordHTTPError.badStatusCode(self)
    }
  }

  /// Makes sure the response is a success response, or tries to find a `JSONError`
  /// so you have a chance to process the error and try to recover.
  ///
  /// Returns `.none` if the response is a success response.
  /// Returns `.jsonError` if it's a recognizable error.
  /// Otherwise returns `.badStatusCode`.
  ///
  /// The `JSONError` does not contain the full Discord error response.
  /// For manual debugging, it's better to directly read the contents of the response:
  /// ```
  /// let httpResponse: DiscordHTTPResponse = ...
  /// print(httpResponse.description)
  /// ```
  @inlinable
  public func asError() -> DiscordHTTPErrorResponse? {
    if (200..<300).contains(self.status.code) {
      return .none
    } else {
      if let error = try? self._decode(as: JSONError.self) {
        return .jsonError(error)
      } else {
        return .badStatusCode(self)
      }
    }
  }

  /// Decodes the response into `JSONError` or throws.
  @inlinable
  public func decodeJSONError() throws -> JSONError {
    if (200..<300).contains(self.status.code) {
      throw DiscordHTTPError.cantDecodeJSONErrorFromSuccessfulResponse(self)
    } else {
      return try self._decode(as: JSONError.self)
    }
  }

  /// Decodes the response into an arbitrary type.
  @inlinable
  public func decode<D: Decodable>(as _: D.Type = D.self) throws -> D {
    try self.guardSuccess()
    return try self._decode()
  }

  /// Doesn't check for success of the response
  @usableFromInline
  func _decode<D: Decodable>(as _: D.Type = D.self) throws -> D {
    if let data = body.map({ Data(buffer: $0, byteTransferStrategy: .noCopy) })
    {
      do {
        return try DiscordGlobalConfiguration.decoder.decode(D.self, from: data)
      } catch {
        throw DiscordHTTPError.decodingError(
          typeName: Swift._typeName(D.self),
          response: self,
          error: error
        )
      }
    } else {
      throw DiscordHTTPError.emptyBody(self)
    }
  }
}

/// Represents a Discord HTTP response for endpoints that return some data in the body.
public struct DiscordClientResponse<C>: Sendable, CustomStringConvertible
where C: Codable {
  /// The raw http response.
  public let httpResponse: DiscordHTTPResponse

  public init(httpResponse: DiscordHTTPResponse) {
    self.httpResponse = httpResponse
  }

  public var description: String {
    "DiscordClientResponse<\(Swift._typeName(C.self, qualified: true))>(httpResponse: \(self.httpResponse))"
  }

  /// Throws an error if the response does not indicate success.
  @inlinable
  public func guardSuccess() throws {
    try self.httpResponse.guardSuccess()
  }

  /// Makes sure the response is a success response, or tries to find a `JSONError`
  /// so you have a chance to process the error and try to recover.
  ///
  /// Returns `.none` if the response is a success response.
  /// Returns `.jsonError` if it's a recognizable error.
  /// Otherwise returns `.badStatusCode`.
  ///
  /// The `JSONError` does not contain the full Discord error response.
  /// For manual debugging, it's better to directly read the contents of the response:
  /// ```
  /// let httpResponse: DiscordHTTPResponse = ...
  /// print(httpResponse.description)
  /// ```
  @inlinable
  public func asError() -> DiscordHTTPErrorResponse? {
    self.httpResponse.asError()
  }

  /// Decodes the response into `JSONError` or throws.
  @inlinable
  public func decodeJSONError() throws -> JSONError {
    try self.httpResponse.decodeJSONError()
  }

  /// Decodes the response.
  @inlinable
  public func decode() throws -> C {
    try httpResponse.decode(as: C.self)
  }
}

/// Represents a Discord HTTP response for CDN endpoints.
public struct DiscordCDNResponse: Sendable, CustomStringConvertible {
  /// The raw http response.
  public let httpResponse: DiscordHTTPResponse
  /// The fallback name for the file that will be decoded.
  public let fallbackFileName: String

  public init(httpResponse: DiscordHTTPResponse, fallbackFileName: String) {
    self.httpResponse = httpResponse
    self.fallbackFileName = fallbackFileName
  }

  public var description: String {
    "DiscordCDNResponse(httpResponse: \(self.httpResponse), fallbackFileName: \"\(self.fallbackFileName)\")"
  }

  @inlinable
  public func guardSuccess() throws {
    try self.httpResponse.guardSuccess()
  }

  @inlinable
  public func getFile(overrideName: String? = nil) throws -> RawFile {
    try self.guardSuccess()
    guard let body = self.httpResponse.body else {
      throw DiscordHTTPError.emptyBody(httpResponse)
    }
    guard
      let contentType = self.httpResponse.headers.first(name: "Content-Type")
    else {
      throw DiscordHTTPError.noContentTypeHeader(httpResponse)
    }
    let name = overrideName ?? fallbackFileName
    return RawFile(data: body, nameNoExtension: name, contentType: contentType)
  }
}

/// Represents a possible Discord HTTP error.
/// Is conformed to `Error` so users can conveniently throw it.
public enum DiscordHTTPErrorResponse: Error, CustomStringConvertible {
  /// The error is in a recognizable format and you can attempt to recover from it.
  case jsonError(JSONError)
  /// The error was not in a recognizable format, but the status code still indicates a failure.
  case badStatusCode(DiscordHTTPResponse)

  public var description: String {
    switch self {
    case let .jsonError(jsonError):
      return "DiscordHTTPErrorResponse.jsonError(\(jsonError))"
    case let .badStatusCode(response):
      return "DiscordHTTPErrorResponse.badStatusCode(\(response))"
    }
  }
}

public enum DiscordHTTPError: Error, CustomStringConvertible {
  /// Your rate-limits have been exhausted for '\(url)'. Try to send less messages or send at a slower pace.
  case rateLimited(url: String)
  /// Discord responded with a non-200 status code.
  case badStatusCode(DiscordHTTPResponse)
  /// Discord responded with a 200 status code but you requested DiscordBM to decode a `JSONError`.
  case cantDecodeJSONErrorFromSuccessfulResponse(DiscordHTTPResponse)
  /// The response body was unexpectedly empty. If it happens frequently, you should report it to me at https://github.com/DiscordBM/DiscordBM/issues.
  case emptyBody(DiscordHTTPResponse)
  /// Discord didn't send a Content-Type header. See if they mentions any errors in the response.
  case noContentTypeHeader(DiscordHTTPResponse)
  /// The endpoint requires an authentication header but you have not passed authentication info in the 'DefaultDiscordClient' initializer.
  case authenticationHeaderRequired(request: DiscordHTTPRequest)
  /// Could not decode to type '\(typeName)'. Make sure your Codable types match the response that Discord sends.
  case decodingError(
    typeName: String, response: DiscordHTTPResponse, error: any Error)
  /// The 'appId' parameter is required. Either pass it in the initializer of DefaultDiscordClient/BotGatewayManager or use the 'appId' function parameter
  case appIdParameterRequired
  /// Discord only accepts one of these query parameters at a time.
  case queryParametersMutuallyExclusive(queries: [(String, String)])
  /// The query parameter '\(name)' with a value of '\(value ?? "nil")' is out of the Discord-acceptable bounds of \(lowerBound)...\(upperBound).
  case queryParameterOutOfBounds(
    name: String, value: String?, lowerBound: Int, upperBound: Int)

  public var description: String {
    switch self {
    case let .rateLimited(url):
      return "DiscordHTTPError.rateLimited(url: \(url))"
    case let .badStatusCode(response):
      return "DiscordHTTPError.badStatusCode(\(response))"
    case let .cantDecodeJSONErrorFromSuccessfulResponse(response):
      return
        "DiscordHTTPError.cantDecodeJSONErrorFromSuccessfulResponse(\(response))"
    case let .emptyBody(response):
      return "DiscordHTTPError.emptyBody(\(response))"
    case let .noContentTypeHeader(response):
      return "DiscordHTTPError.noContentTypeHeader(\(response))"
    case let .authenticationHeaderRequired(request):
      return
        "DiscordHTTPError.authenticationHeaderRequired(request: \(request))"
    case let .decodingError(typeName, response, error):
      return
        "DiscordHTTPError.decodingError(typeName: \(typeName), response: \(response), error: \(error))"
    case .appIdParameterRequired:
      return "DiscordHTTPError.appIdParameterRequired"
    case let .queryParametersMutuallyExclusive(queries):
      return
        "DiscordHTTPError.queryParametersMutuallyExclusive(queries: \(queries))"
    case let .queryParameterOutOfBounds(name, value, lowerBound, upperBound):
      return
        "DiscordHTTPError.queryParameterOutOfBounds(name: \(name), value: \(value ?? "nil"), lowerBound: \(lowerBound), upperBound: \(upperBound))"
    }
  }
}
