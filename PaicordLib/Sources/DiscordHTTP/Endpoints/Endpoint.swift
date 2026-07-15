import NIOHTTP1

public protocol Endpoint: Sendable, CustomStringConvertible {
  var url: String { get }
  /// Doesn't expose secret url path parameters.
  var urlDescription: String { get }
  var httpMethod: HTTPMethod { get }
  /// Interaction endpoints don't count against the global rate limit.
  /// Even if the global rate-limit is exceeded, you can still respond to interactions.
  /// So this is used for interaction endpoints.
  var countsAgainstGlobalRateLimit: Bool { get }
  /// Some endpoints don't require an authorization header, sometimes because the endpoint url
  /// itself contains some kind of authorization token. Like some of the webhook endpoints.
  var requiresAuthorizationHeader: Bool { get }
  /// Path parameters.
  var parameters: [String] { get }
  var id: Int { get }
}

/// Just to switch between the 4 endpoint types.
public enum AnyEndpoint: Endpoint {
  case userApi(UserAPIEndpoint)
  case api(APIEndpoint)
  case cdn(CDNEndpoint)
  case loose(LooseEndpoint)

  /// This case serves as a way of discouraging exhaustive switch statements
  case __DO_NOT_USE_THIS_CASE

  public var url: String {
    switch self {
    case .api(let endpoint):
      return endpoint.url
    case .userApi(let endpoint):
      return endpoint.url
    case .cdn(let endpoint):
      return endpoint.url
    case .loose(let endpoint):
      return endpoint.url
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var urlDescription: String {
    switch self {
    case .api(let endpoint):
      return endpoint.urlDescription
    case .userApi(let endpoint):
      return endpoint.urlDescription
    case .cdn(let endpoint):
      return endpoint.urlDescription
    case .loose(let endpoint):
      return endpoint.urlDescription
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var httpMethod: HTTPMethod {
    switch self {
    case .api(let endpoint):
      return endpoint.httpMethod
    case .userApi(let endpoint):
      return endpoint.httpMethod
    case .cdn(let endpoint):
      return endpoint.httpMethod
    case .loose(let endpoint):
      return endpoint.httpMethod
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var countsAgainstGlobalRateLimit: Bool {
    switch self {
    case .api(let endpoint):
      return endpoint.countsAgainstGlobalRateLimit
    case .userApi(let endpoint):
      return endpoint.countsAgainstGlobalRateLimit
    case .cdn(let endpoint):
      return endpoint.countsAgainstGlobalRateLimit
    case .loose(let endpoint):
      return endpoint.countsAgainstGlobalRateLimit
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var requiresAuthorizationHeader: Bool {
    switch self {
    case .api(let endpoint):
      return endpoint.requiresAuthorizationHeader
    case .userApi(let endpoint):
      return endpoint.requiresAuthorizationHeader
    case .cdn(let endpoint):
      return endpoint.requiresAuthorizationHeader
    case .loose(let endpoint):
      return endpoint.requiresAuthorizationHeader
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var parameters: [String] {
    switch self {
    case .api(let endpoint):
      return endpoint.parameters
    case .userApi(let endpoint):
      return endpoint.parameters
    case .cdn(let endpoint):
      return endpoint.parameters
    case .loose(let endpoint):
      return endpoint.parameters
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var id: Int {
    switch self {
    case .api(let endpoint):
      return endpoint.id
    case .userApi(let endpoint):
      return endpoint.id
    case .cdn(let endpoint):
      return -endpoint.id
    case .loose(let endpoint):
      return endpoint.id
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var description: String {
    switch self {
    case .api(let endpoint):
      return "AnyEndpoint.botApi(\(endpoint))"
    case .userApi(let endpoint):
      return "AnyEndpoint.userApi(\(endpoint))"
    case .cdn(let endpoint):
      return "AnyEndpoint.cdn(\(endpoint))"
    case .loose(let endpoint):
      return "AnyEndpoint.loose(\(endpoint))"
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }
}
