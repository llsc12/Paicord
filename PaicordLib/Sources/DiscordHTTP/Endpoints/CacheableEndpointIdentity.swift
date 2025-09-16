/// The endpoints that can be cached. Basically the GET endpoints.
/// UNSTABLE ENUM, DO NOT USE EXHAUSTIVE SWITCH STATEMENTS.
public enum CacheableEndpointIdentity: Sendable, Hashable,
  CustomStringConvertible
{
  case api(CacheableAPIEndpointIdentity)
  case cdn(CDNEndpointIdentity)
  case loose(LooseEndpoint)

  /// This case serves as a way of discouraging exhaustive switch statements
  case __DO_NOT_USE_THIS_CASE

  @usableFromInline
  init?(endpoint: AnyEndpoint) {
    switch endpoint {
    case let .userApi(endpoint):
      if let endpoint = CacheableAPIEndpointIdentity(endpoint: endpoint) {
        self = .api(endpoint)
      } else {
        return nil
      }
    case let .botApi(endpoint):
      if let endpoint = CacheableAPIEndpointIdentity(endpoint: endpoint) {
        self = .api(endpoint)
      } else {
        return nil
      }
    case let .cdn(endpoint):
      self = .cdn(CDNEndpointIdentity(endpoint: endpoint))
    case let .loose(endpoint):
      self = .loose(endpoint)
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var description: String {
    switch self {
    case .api(let endpoint):
      return "CacheableEndpointIdentity.api(\(endpoint))"
    case .cdn(let endpoint):
      return "CacheableEndpointIdentity.cdn(\(endpoint))"
    case .loose(let endpoint):
      return "CacheableEndpointIdentity.loose(\(endpoint))"
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }
}
