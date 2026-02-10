import AsyncHTTPClient
import Atomics
import DiscordModels
import Foundation
import SkipFuse
import NIOCore
import NIOFoundationCompat
import NIOHTTP1

public struct DefaultDiscordClient: DiscordClient {
  public let client: HTTPClient
  public let authentication: AuthenticationHeader
  public let appId: ApplicationSnowflake?
  public let configuration: ClientConfiguration
  public let logger = DiscordGlobalConfiguration.makeLogger(
    "DefaultDiscordClient"
  )

  public var captchaCallback: CaptchaChallengeHandler? = nil
  public var mfaCallback: MFAVerificationHandler? = nil

  /// Discord apparently looks at this for figuring out library-usages.
  /// Technically they could also look at the info passed in Gateway's identify payload, for that.
  /// From what I've figured, if Discord sees a lot of people are using the same library, they
  /// will contact the owner and add the library to the list of suggested libraries on their website.
  public var userAgent: String {
    // only use the default bot useragent of discordbm if it is a bot token
    if self.authentication.userMode {
      return SuperProperties.useragent(ws: false)!
    } else {
      return "DiscordBM (https://github.com/discordbm/discordbm, 1.0.0)"
    }
  }

  /// Use `getCache()` to get the appropriate cache.

  /// The cache used for requests that require an auth header.
  @usableFromInline
  let _authCache: ClientCache

  /// Stores cookies
  @usableFromInline
  let _cookieStore: CookieStore = .init()

  @usableFromInline
  static let requestIdGenerator = ManagedAtomic(UInt(0))

  /// The fact that this could be used by multiple different `DiscordClient`s with
  /// different `token`s should not matter because buckets are random anyway.
  @usableFromInline
  static let rateLimiter = HTTPRateLimiter(label: "DiscordClientRateLimiter")

  /// - Parameters:
  ///   - httpClient: A ``HTTPClient``.
  ///   - token: Must be a **bot token**.
  ///   - appId: Your Discord application-id. If not provided, it'll be extracted from bot token.
  ///   This is used as a default when no app-id is passed to a ``DiscordClient`` function.
  ///   - configuration: The configuration affecting this ``DefaultDiscordClient``.
  public init(
    httpClient: HTTPClient = .shared,
    token: Secret,
    appId: ApplicationSnowflake? = nil,
    configuration: ClientConfiguration = .init(),
    captchaCallback: CaptchaChallengeHandler? = nil,
    mfaCallback: MFAVerificationHandler? = nil
  ) async {
    self.captchaCallback = captchaCallback
    self.mfaCallback = mfaCallback
    self.client = httpClient
    self.authentication = .botToken(token)
    self.appId = appId ?? self.authentication.extractAppIdIfAvailable()
    self.configuration = configuration
    self._authCache = await ClientCacheStorage.shared.cache(
      for: self.authentication
    )
  }

  /// - Parameters:
  ///   - httpClient: A ``HTTPClient``.
  ///   - token: Must be a **bot token**.
  ///   - appId: Your Discord application-id. If not provided, it'll be extracted from bot token.
  ///   This is used as a default when no app-id is passed to a ``DiscordClient`` function.
  ///   - configuration: The configuration affecting this ``DefaultDiscordClient``.
  public init(
    httpClient: HTTPClient = .shared,
    token: String,
    appId: ApplicationSnowflake? = nil,
    configuration: ClientConfiguration = .init()
  ) async {
    self.client = httpClient
    self.authentication = .botToken(Secret(token))
    self.appId = appId ?? self.authentication.extractAppIdIfAvailable()
    self.configuration = configuration
    self._authCache = await ClientCacheStorage.shared.cache(
      for: self.authentication
    )
  }

  /// - Parameters:
  ///   - httpClient: A ``HTTPClient``.
  ///   - token: Must be a **bot token**.
  ///   - appId: Your Discord application-id. If not provided, it'll be extracted from bot token.
  ///   This is used as a default when no app-id is passed to a ``DiscordClient`` function.
  ///   - configuration: The configuration affecting this ``DefaultDiscordClient``.
  public init(
    httpClient: HTTPClient = .shared,
    header: AuthenticationHeader,
    appId: ApplicationSnowflake? = nil,
    configuration: ClientConfiguration = .init(),
    captchaCallback: CaptchaChallengeHandler? = nil,
    mfaCallback: MFAVerificationHandler? = nil
  ) async {
    self.captchaCallback = captchaCallback
    self.mfaCallback = mfaCallback
    self.client = httpClient
    self.authentication = header
    self.appId = appId ?? self.authentication.extractAppIdIfAvailable()
    self.configuration = configuration
    self._authCache = await ClientCacheStorage.shared.cache(
      for: self.authentication
    )
  }

  /// - Parameters:
  ///   - httpClient: A ``HTTPClient``.
  ///   - oAuthToken: Must be an **OAuth token**.
  ///   - appId: Your Discord application-id. It **can't** be extracted from the token, if not provided.
  ///   This is used as a default when no app-id is passed to a ``DiscordClient`` function.
  ///   - configuration: The configuration affecting this ``DefaultDiscordClient``.
  public init(
    httpClient: HTTPClient = .shared,
    oAuthToken: Secret,
    appId: ApplicationSnowflake? = nil,
    configuration: ClientConfiguration = .init()
  ) async {
    self.client = httpClient
    self.authentication = .oAuthToken(oAuthToken)
    /// OAuth tokens don't contain an app-id to extract
    self.appId = appId
    self.configuration = configuration
    self._authCache = await ClientCacheStorage.shared.cache(
      for: self.authentication
    )
  }

  /// - Parameters:
  ///   - httpClient: A ``HTTPClient``.
  ///   - oAuthToken: Must be an **OAuth token**.
  ///   - appId: Your Discord application-id. It **can't** be extracted from the token, if not provided.
  ///   This is used as a default when no app-id is passed to a ``DiscordClient`` function.
  ///   - configuration: The configuration affecting this ``DefaultDiscordClient``.
  public init(
    httpClient: HTTPClient = .shared,
    oAuthToken: String,
    appId: ApplicationSnowflake? = nil,
    configuration: ClientConfiguration = .init()
  ) async {
    self.client = httpClient
    self.authentication = .oAuthToken(Secret(oAuthToken))
    /// OAuth tokens don't contain an app-id to extract
    self.appId = appId
    self.configuration = configuration
    self._authCache = await ClientCacheStorage.shared.cache(
      for: self.authentication
    )
  }

  /// - Parameters:
  ///   - httpClient: A ``HTTPClient``.
  ///   - authentication: The authentication method when sending requests to Discord.
  ///   - appId: Your Discord application-id.
  ///   If `authentication` is a **bot** token, the app-id will be extracted from bot token.
  ///   Otherwise it can't be automatically extracted.
  ///   This is used as a default when no app-id is passed to a ``DiscordClient`` function.
  ///   - configuration: The configuration affecting this ``DefaultDiscordClient``.
  public init(
    httpClient: HTTPClient = .shared,
    authentication: AuthenticationHeader,
    appId: ApplicationSnowflake? = nil,
    configuration: ClientConfiguration = .init()
  ) async {
    self.client = httpClient
    self.authentication = authentication
    self.appId = appId ?? self.authentication.extractAppIdIfAvailable()
    self.configuration = configuration
    self._authCache = await ClientCacheStorage.shared.cache(
      for: self.authentication
    )
  }

  /// - Parameters:
  ///   - httpClient: A ``HTTPClient``.
  ///   - appId: Your Discord application-id.
  ///   If `authentication` is a **bot** token, the app-id will be extracted from bot token.
  ///   Otherwise it can't be automatically extracted.
  ///   This is used as a default when no app-id is passed to a ``DiscordClient`` function.
  ///   - configuration: The configuration affecting this ``DefaultDiscordClient``.
  public init(
    httpClient: HTTPClient = .shared,
    configuration: ClientConfiguration = .init(),
    captchaCallback: CaptchaChallengeHandler? = nil,
    mfaCallback: MFAVerificationHandler? = nil
  ) {
    self.captchaCallback = captchaCallback
    self.mfaCallback = mfaCallback
    self.client = httpClient
    self.authentication = captchaCallback == nil ? .none : .userNone
    self.configuration = configuration
    self._authCache = .global
    self.appId = nil
  }

  @inlinable
  func checkRateLimitsAllowRequest(
    to endpoint: AnyEndpoint,
    requestId: UInt,
    retriesSoFar: Int
  ) async throws {
    switch await Self.rateLimiter.shouldRequest(to: endpoint) {
    case .true: return
    case .false:
      /// `HTTPRateLimiter` already logs this.
      throw DiscordHTTPError.rateLimited(url: "\(endpoint.urlDescription)")
    case .after(let after):
      /// If we make the request, we'll get 429-ed. So we can just assume the status is 429.
      if self.configuration.shouldRetry(
        status: .tooManyRequests,
        retriesSoFar: retriesSoFar,
        challengeSolved: false
      ) {
        logger.debug(
          "HTTP bucket is exhausted. Will wait before making the request",
          metadata: [
            "wait-time": .stringConvertible(after),
            "retriesWithoutThis": .stringConvertible(retriesSoFar),
            "endpoint": .stringConvertible(endpoint.urlDescription),
            "request-id": .stringConvertible(requestId),
          ]
        )
        let nanos = UInt64(after * 1_000_000_000)
        try await Task.sleep(for: .nanoseconds(nanos))
        await Self.rateLimiter.addGlobalRateLimitRecord()
      } else {
        logger.warning(
          "HTTP bucket is exhausted. Retry policy does not allow retry",
          metadata: [
            "solution":
              "Make requests slower or increase 'configuration.retryPolicy.backoff.basedOnHeaders.maxAllowed'",
            "wait-time": .stringConvertible(after),
            "retriesWithoutThis": .stringConvertible(retriesSoFar),
            "endpoint": .stringConvertible(endpoint.urlDescription),
            "request-id": .stringConvertible(requestId),
          ]
        )
        throw DiscordHTTPError.rateLimited(url: "\(endpoint.urlDescription)")
      }
    }
  }

  @inlinable
  func includeInRateLimits(
    endpoint: AnyEndpoint,
    headers: HTTPHeaders,
    status: HTTPResponseStatus
  ) async {
    await Self.rateLimiter.include(
      endpoint: endpoint,
      headers: headers,
      status: status
    )
  }

  /// To centralize the way the is-cacheable checking is done.
  /// Because this must be the same in `getFromCache` and `saveInCache`.
  /// Returns the `CacheableEndpointIdentity` and the `TTL`.
  @inlinable
  func isCacheable(identity: CacheableEndpointIdentity?) -> (
    CacheableEndpointIdentity, Duration
  )? {
    guard let identity,
      let ttl = self.configuration.cachingBehavior.getTTL(for: identity)
    else { return nil }
    return (identity, ttl)
  }

  /// Gets the response from cache if available.
  /// If there is another request in queue with the same identity, waits for that to finish.
  /// This means that this func is trusting that a response is always made if this returns `nil`.
  @inlinable
  func getFromCache(
    identity: CacheableEndpointIdentity?,
    requiresAuthHeader: Bool,
    parameters: [String],
    queries: [(String, String?)]
  ) async -> DiscordHTTPResponse? {
    /// Since the `ClientCache` is shared and another `DiscordClient` could have
    /// had added a response to it, at least make sure that this
    /// `DiscordClient` should be using any caching at all for the endpoint.
    guard let (identity, _) = self.isCacheable(identity: identity) else {
      return nil
    }
    return await self.getCache(
      requiresAuthHeader: requiresAuthHeader
    ).get(
      item: .init(
        identity: identity,
        parameters: parameters,
        queries: queries
      )
    )
  }

  @inlinable
  func saveInCache(
    response: DiscordHTTPResponse,
    identity: CacheableEndpointIdentity?,
    requiresAuthHeader: Bool,
    parameters: [String],
    queries: [(String, String?)]
  ) async {
    guard (200..<300).contains(response.status.code),
      let (identity, ttl) = self.isCacheable(identity: identity)
    else {
      return
    }
    await self.getCache(requiresAuthHeader: requiresAuthHeader).save(
      response: response,
      item: .init(
        identity: identity,
        parameters: parameters,
        queries: queries
      ),
      ttl: ttl
    )
    logger.debug(
      "Saved response in cache",
      metadata: [
        "endpointIdentity": .stringConvertible(identity),
        "queries": .stringConvertible(queries),
      ]
    )
  }

  @inlinable
  func unlockRequestsInCache(
    identity: CacheableEndpointIdentity?,
    requiresAuthHeader: Bool,
    parameters: [String],
    queries: [(String, String?)]
  ) async {
    guard let identity = identity else { return }
    await self.getCache(requiresAuthHeader: requiresAuthHeader).unlockRequests(
      forItem: .init(
        identity: identity,
        parameters: parameters,
        queries: queries
      )
    )
  }

  @usableFromInline
  func execute(_ request: HTTPClient.Request) async throws
    -> DiscordHTTPResponse
  {
    DiscordHTTPResponse(
      _response: try await self.client.execute(
        request: request,
        deadline: .now() + configuration.requestTimeoutAmount,
        logger: configuration.enableLoggingForRequests
          ? DiscordGlobalConfiguration.makeLogger("DBM+HTTPClient")
          : Logger(
            label: "DBM-no-op-logger",
            factory: SwiftLogNoOpLogHandler.init
          )
      ).get()
    )
  }

  /// Waits for the next retry if needed, and increases the retry counter.
  @inlinable
  func waitForRetryAndIncreaseRetryCount(
    retriesSoFar: inout Int,
    headers: HTTPHeaders,
    requestId: UInt
  ) async throws {
    let retryWait = self.configuration.waitTimeBeforeRetry(
      retriesSoFar: retriesSoFar,
      headers: headers
    )
    logger.debug(
      "Will soon retry a request",
      metadata: [
        "request-id": .stringConvertible(requestId),
        "retriesWithoutThis": .stringConvertible(retriesSoFar),
        "waitSecondsBeforeRetry": .stringConvertible(retryWait ?? 0),
      ]
    )
    if let retryWait {
      try await Task.sleep(for: .nanoseconds(UInt64(retryWait * 1_000_000_000)))
    }
    retriesSoFar += 1
    logger.trace(
      "Will retry a request right now",
      metadata: [
        "request-id": .stringConvertible(requestId),
        "retriesWithoutThis": .stringConvertible(retriesSoFar),
      ]
    )
  }

  /// Returns an appropriate `ClientCache`.
  @usableFromInline
  func getCache(requiresAuthHeader: Bool) -> ClientCache {
    if requiresAuthHeader {
      return self._authCache
    } else {
      return .global
    }
  }

  /// Sends requests and retries if needed.
  @inlinable
  func sendWithRetries(
    request req: DiscordHTTPRequest,
    sendRequest: (CacheableEndpointIdentity?, Int, UInt, HTTPHeaders?)
      async throws -> (
        DiscordHTTPResponse, Bool
      )
  ) async throws -> DiscordHTTPResponse {
    let identity = CacheableEndpointIdentity(endpoint: req.endpoint)
    let requestId = Self.requestIdGenerator.wrappingIncrementThenLoad(
      ordering: .relaxed
    )

    var retriesSoFar = 0
    var cached = false
    var response: DiscordHTTPResponse
    var headers: HTTPHeaders

    do {
      (response, cached) = try await sendRequest(
        identity,
        retriesSoFar,
        requestId,
        nil
      )
      headers = response.headers

      await _cookieStore.checkIncomingHeaders(headers)

      // Check for captcha challenge
      // this variable will be flipped to true if either captcha was solved or mfa was passed
      var challengeSolved = false

      if let captchaData = extractCaptchaChallenge(from: response) {
        if let captchaHeaderData = await captchaCallback?(captchaData) {
          headers.replaceOrAdd(
            name: "X-Captcha-Key", value: captchaHeaderData.solutionToken)
          if let sessionID = captchaHeaderData.captchaSessionId {
            headers.replaceOrAdd(
              name: "X-Captcha-Session-Id", value: sessionID)
          }
          if let rqToken = captchaHeaderData.captchaRqtoken {
            headers.replaceOrAdd(
              name: "X-Captcha-Rqtoken", value: rqToken)
          }
          challengeSolved = true
        }
      }

      if let mfaHeader = extractMFAVerification(from: response) {
        if let mfaResponse = await mfaCallback?(mfaHeader) {
          headers.replaceOrAdd(name: "X-Discord-MFA-Authorization", value: mfaResponse.token)
          challengeSolved = true
        }
      }

      while configuration.shouldRetry(
        status: response.status,
        retriesSoFar: retriesSoFar,
        challengeSolved: challengeSolved
      ) {
        try await waitForRetryAndIncreaseRetryCount(
          retriesSoFar: &retriesSoFar,
          headers: headers,
          requestId: requestId
        )
        (response, cached) = try await sendRequest(
          identity,
          retriesSoFar,
          requestId,
          headers
        )
        headers = response.headers
      }
    } catch {
      if !cached {
        await self.unlockRequestsInCache(
          identity: identity,
          requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
          parameters: req.endpoint.parameters,
          queries: req.queries
        )
      }

      throw error
    }

    if !cached {
      await self.saveInCache(
        response: response,
        identity: identity,
        requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
        parameters: req.endpoint.parameters,
        queries: req.queries
      )
      await self.unlockRequestsInCache(
        identity: identity,
        requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
        parameters: req.endpoint.parameters,
        queries: req.queries
      )
    }

    return response
  }

  @inlinable
  public func send(request req: DiscordHTTPRequest) async throws
    -> DiscordHTTPResponse
  {
    try await self.sendWithRetries(request: req) {
      identity,
      retryCounter,
      requestId,
      overrideHeaders in

      if let cached = await self.getFromCache(
        identity: identity,
        requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
        parameters: req.endpoint.parameters,
        queries: req.queries
      ) {
        logger.debug(
          "Got cached response",
          metadata: [
            "endpoint": .string(req.endpoint.urlDescription),
            "queries": .stringConvertible(req.queries),
            "retry": .stringConvertible(retryCounter),
          ]
        )
        return (cached, true)
      }

      try await self.checkRateLimitsAllowRequest(
        to: req.endpoint,
        requestId: requestId,
        retriesSoFar: retryCounter
      )
      var request = try HTTPClient.Request(
        url: req.endpoint.url + req.queries.makeForURLQuery(),
        method: req.endpoint.httpMethod
      )
      request.headers = overrideHeaders ?? req.headers
      request.headers.add(name: "User-Agent", value: userAgent)
      if authentication.userMode {
        try self.addUserHeaders(&request.headers)
        await _cookieStore.applyCookies(to: &request.headers)
      }
      if req.endpoint.requiresAuthorizationHeader {
        try self.authentication.addHeader(
          headers: &request.headers,
          request: req
        )
      }

      logger.debug(
        "Will send a request to Discord",
        metadata: [
          "url": .stringConvertible(
            req.endpoint.urlDescription + req.queries.makeForURLQuery()
          ),
          "method": .string(request.method.rawValue),
          "retry": .stringConvertible(retryCounter),
          "request-id": .stringConvertible(requestId),
        ]
      )
      let response = try await self.execute(request)
      logger.debug(
        "Received a response from Discord",
        metadata: [
          "response": .stringConvertible(response),
          "retry": .stringConvertible(retryCounter),
          "request-id": .stringConvertible(requestId),
        ]
      )

      await self.includeInRateLimits(
        endpoint: req.endpoint,
        headers: response.headers,
        status: response.status
      )

      return (response, false)
    }
  }

  @inlinable
  public func send<E: Sendable & Encodable & ValidatablePayload>(
    request req: DiscordHTTPRequest,
    payload: E
  ) async throws -> DiscordHTTPResponse {
    if configuration.performValidations {
      try payload.validate().throw(model: payload)
    }

    return try await self.sendWithRetries(request: req) {
      identity,
      retryCounter,
      requestId,
      overrideHeaders in

      let identity = CacheableEndpointIdentity(endpoint: req.endpoint)
      if let cached = await self.getFromCache(
        identity: identity,
        requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
        parameters: req.endpoint.parameters,
        queries: req.queries
      ) {
        return (cached, true)
      }
      if let cached = await self.getFromCache(
        identity: identity,
        requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
        parameters: req.endpoint.parameters,
        queries: req.queries
      ) {
        logger.debug(
          "Got cached response",
          metadata: [
            "endpoint": .string(req.endpoint.urlDescription),
            "queries": .stringConvertible(req.queries),
            "retry": .stringConvertible(retryCounter),
          ]
        )
        return (cached, true)
      }

      try await self.checkRateLimitsAllowRequest(
        to: req.endpoint,
        requestId: requestId,
        retriesSoFar: retryCounter
      )

      let data = try DiscordGlobalConfiguration.encoder.encode(payload)
      var request = try HTTPClient.Request(
        url: req.endpoint.url + req.queries.makeForURLQuery(),
        method: req.endpoint.httpMethod
      )
      request.headers = overrideHeaders ?? req.headers
      request.headers.add(name: "User-Agent", value: userAgent)
      if authentication.userMode {
        try self.addUserHeaders(&request.headers)
        await _cookieStore.applyCookies(to: &request.headers)
      }
      request.headers.replaceOrAdd(
        name: "Content-Type",
        value: "application/json"
      )
      if req.endpoint.requiresAuthorizationHeader {
        try self.authentication.addHeader(
          headers: &request.headers,
          request: req
        )
      }

      request.body = .bytes(data)

      logger.debug(
        "Will send a request to Discord",
        metadata: [
          "body": .string(String(data: data, encoding: .utf8) ?? "nil"),
          "url": .stringConvertible(
            req.endpoint.urlDescription + req.queries.makeForURLQuery()
          ),
          "method": .string(request.method.rawValue),
          "retry": .stringConvertible(retryCounter),
          "request-id": .stringConvertible(requestId),
        ]
      )
      let response = try await self.execute(request)
      logger.debug(
        "Received a response from Discord",
        metadata: [
          "response": .stringConvertible(response),
          "retry": .stringConvertible(retryCounter),
          "request-id": .stringConvertible(requestId),
        ]
      )

      await self.includeInRateLimits(
        endpoint: req.endpoint,
        headers: response.headers,
        status: response.status
      )

      return (response, false)
    }
  }

  @inlinable
  public func sendMultipart<
    E: Sendable & MultipartEncodable & ValidatablePayload
  >(
    request req: DiscordHTTPRequest,
    payload: E
  ) async throws -> DiscordHTTPResponse {
    if configuration.performValidations {
      try payload.validate().throw(model: payload)
    }

    return try await self.sendWithRetries(request: req) {
      identity,
      retryCounter,
      requestId,
      overrideHeaders in

      let identity = CacheableEndpointIdentity(endpoint: req.endpoint)
      if let cached = await self.getFromCache(
        identity: identity,
        requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
        parameters: req.endpoint.parameters,
        queries: req.queries
      ) {
        return (cached, true)
      }
      if let cached = await self.getFromCache(
        identity: identity,
        requiresAuthHeader: req.endpoint.requiresAuthorizationHeader,
        parameters: req.endpoint.parameters,
        queries: req.queries
      ) {
        logger.debug(
          "Got cached response",
          metadata: [
            "endpoint": .string(req.endpoint.urlDescription),
            "queries": .stringConvertible(req.queries),
            "retry": .stringConvertible(retryCounter),
          ]
        )
        return (cached, true)
      }

      try await self.checkRateLimitsAllowRequest(
        to: req.endpoint,
        requestId: requestId,
        retriesSoFar: retryCounter
      )

      let contentType: String
      let buffer: ByteBuffer
      if let multipart = try payload.encodeMultipart() {
        contentType =
          "multipart/form-data; boundary=\(MultipartConfiguration.boundary)"
        buffer = multipart
      } else {
        contentType = "application/json"
        buffer = ByteBuffer(
          data: try DiscordGlobalConfiguration.encoder.encode(payload)
        )
      }
      var request = try HTTPClient.Request(
        url: req.endpoint.url + req.queries.makeForURLQuery(),
        method: req.endpoint.httpMethod
      )
      request.headers = overrideHeaders ?? req.headers
      request.headers.add(name: "User-Agent", value: userAgent)
      if authentication.userMode {
        try self.addUserHeaders(&request.headers)
        await _cookieStore.applyCookies(to: &request.headers)
      }
      request.headers.replaceOrAdd(name: "Content-Type", value: contentType)
      if req.endpoint.requiresAuthorizationHeader {
        try self.authentication.addHeader(
          headers: &request.headers,
          request: req
        )
      }

      request.body = .byteBuffer(buffer)

      logger.debug(
        "Will send a request to Discord",
        metadata: [
          "body": .string(String(buffer: buffer)),
          "url": .stringConvertible(
            req.endpoint.urlDescription + req.queries.makeForURLQuery()
          ),
          "method": .string(request.method.rawValue),
          "retry": .stringConvertible(retryCounter),
          "request-id": .stringConvertible(requestId),
        ]
      )
      let response = try await self.execute(request)
      logger.debug(
        "Received a response from Discord",
        metadata: [
          "response": .stringConvertible(response),
          "retry": .stringConvertible(retryCounter),
          "request-id": .stringConvertible(requestId),
        ]
      )

      await self.includeInRateLimits(
        endpoint: req.endpoint,
        headers: response.headers,
        status: response.status
      )

      return (response, false)
    }
  }

  @usableFromInline
  func extractCaptchaChallenge(from response: DiscordHTTPResponse)
    -> CaptchaChallengeData?
  {
    guard response.status.code == 400,
      let data = response.body,
      let json = try? JSONSerialization.jsonObject(with: data, options: [])
        as? [String: Any],
      let captchaService = json["captcha_service"] as? String,
      let captchaKey = json["captcha_key"] as? [String]
    else { return nil }

    return CaptchaChallengeData(
      captchaKey: captchaKey,
      captchaService: captchaService,
      captchaSiteKey: json["captcha_sitekey"] as? String,
      captchaSessionId: json["captcha_session_id"] as? String,
      captchaRqdata: json["captcha_rqdata"] as? String,
      captchaRqtoken: json["captcha_rqtoken"] as? String,
      shouldServeInvisible: json["should_serve_invisible"] as? Bool
    )
  }

  @usableFromInline
  func extractMFAVerification(from response: DiscordHTTPResponse)
    -> MFAVerificationData?
  {
    guard response.status.code == 401,
      let data = response.body,
      let json = try? JSONSerialization.jsonObject(with: data, options: [])
        as? [String: Any],  // error object but with mfa field
      json["code"] as? Int == 60003,  // MFA required error code
      let mfa = json["mfa"] as? String,  // MFA verification request object
      let mfaData = mfa.data(using: .utf8),
      let mfaRequest = try? DiscordGlobalConfiguration.decoder.decode(
        MFAVerificationData.self, from: mfaData)
    else { return nil }

    return mfaRequest
  }

  @inlinable
  func addUserHeaders(_ headers: inout HTTPHeaders) throws {
    // discord special headers
    let superProperties = SuperProperties.GenerateSuperPropertiesHeader()
    let locale = SuperProperties.GenerateLocaleHeader()
    let timezone = SuperProperties.GenerateTimezoneHeader()
    headers.add(name: "X-Super-Properties", value: superProperties)
    headers.add(name: "X-Discord-Locale", value: locale)
    headers.add(name: "X-Discord-Timezone", value: timezone)
    headers.add(name: "X-Debug-Options", value: "bugReporterEnabled")

    // general
    headers.add(name: "Accept", value: "*/*")
    headers.add(name: "Accept-Language", value: locale)
    headers.add(name: "Priority", value: "u=1, i")

    #if os(macOS)
      headers.add(name: "Sec-Fetch-Dest", value: "empty")
      headers.add(name: "Sec-Fetch-Mode", value: "cors")
      headers.add(name: "Sec-Fetch-Site", value: "same-origin")
      headers.add(name: "Sec-CH-UA-Mobile", value: "?0")
      headers.add(name: "Sec-CH-UA-Platform", value: "\"macOS\"")  // in speechmarks
      headers.add(
        name: "Sec-CH-UA",
        value: "\"Not:A-Brand\";v=\"24\", \"Chromium\";v=\"134\"")  // in speechmarks
      /// dolfies says this being static is ok, though im thinking about login flows bc it'd have like https://discord.com/login as referer
      headers.add(name: "Referer", value: "https://discord.com/channels/@me")
      headers.add(name: "Origin", value: "https://discord.com")

    #elseif os(iOS)
      // lol theres no special headers on ios, they all mirror the shared headers
    #endif
  }
}
