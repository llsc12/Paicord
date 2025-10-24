import struct Foundation.Date
import typealias Foundation.TimeInterval

/// This doesn't use the `Cache-Control` header because I couldn't
/// find a 2xx response with a `Cache-Control` header returned by Discord.
@usableFromInline
actor ClientCache {

  @usableFromInline
  struct CacheableItem: Sendable, Hashable {
    let identity: CacheableEndpointIdentity
    let parameters: [String]
    let queries: [(String, String?)]

    @usableFromInline
    init(
      identity: CacheableEndpointIdentity, parameters: [String],
      queries: [(String, String?)]
    ) {
      self.identity = identity
      self.parameters = parameters
      self.queries = queries
    }

    @usableFromInline
    func hash(into hasher: inout Hasher) {
      switch identity {
      case .api(let endpoint):
        hasher.combine(0)
        endpoint.hash(into: &hasher)
      case .userApi(let endpoint):
        hasher.combine(1)
        endpoint.hash(into: &hasher)
      case .cdn(let endpoint):
        hasher.combine(2)
        endpoint.hash(into: &hasher)
      case .loose(let endpoint):
        hasher.combine(3)
        endpoint.hash(into: &hasher)
      case .__DO_NOT_USE_THIS_CASE:
        fatalError(
          "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
        )
      }
      for param in parameters {
        hasher.combine(param)
      }
      for (key, value) in queries {
        hasher.combine(key)
        hasher.combine(value)
      }
    }

    @usableFromInline
    static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.identity == rhs.identity && lhs.parameters == rhs.parameters
        && lhs.queries.elementsEqual(
          rhs.queries,
          by: {
            $0.0 == $1.0 && $0.1 == $1.1
          }
        )
    }
  }

  /// [ID: ExpirationTime]
  var timeTable = [CacheableItem: Double]()
  /// [ID: ExpirationTime]
  var pendingContinuations = [
    CacheableItem: [CheckedContinuation<Void, Never>]
  ]()
  var lockedItems = Set<CacheableItem>()
  /// [ID: Response]
  var storage = [CacheableItem: DiscordHTTPResponse]()

  static let global = ClientCache()

  init() {
    Task { await self.collectGarbage() }
  }

  @usableFromInline
  func save(response: DiscordHTTPResponse, item: CacheableItem, ttl: Duration) {
    self.timeTable[item] = Date().timeIntervalSince1970 + ttl.asTimeInterval
    self.storage[item] = response
  }

  /// Gets the item from cache, or acquires a lock for the item.
  /// A request **must** be made if this returns `nil`.
  @usableFromInline
  func get(item: CacheableItem) async -> DiscordHTTPResponse? {
    /// If insert is successful, it means the lock was acquired.
    /// If the insert is unsuccessful, it means there is another request being made
    /// and this request needs to wait for that.
    if !lockedItems.insert(item).inserted {
      await withCheckedContinuation { continuation in
        self.pendingContinuations[item, default: []].append(continuation)
      }
      return await self.get(item: item)
    }

    if let time = self.timeTable[item] {
      if time > Date().timeIntervalSince1970 {
        if let existing = storage[item] {
          /// Unlock if the item existed
          self.unlockRequests(forItem: item)
          return existing
        } else {
          return nil
        }
      } else {
        self.timeTable[item] = nil
        self.storage[item] = nil
        return nil
      }
    } else {
      return nil
    }
  }

  /// Unlock making other requests with for the same `item` identity.
  @usableFromInline
  func unlockRequests(forItem item: CacheableItem) {
    for continuation in self.pendingContinuations.removeValue(forKey: item)
      ?? []
    {
      continuation.resume()
    }
    self.lockedItems.remove(item)
  }

  private func collectGarbage() async {
    /// Quit in case of task cancelation.
    guard (try? await Task.sleep(for: .seconds(60))) != nil else { return }
    let now = Date().timeIntervalSince1970
    for (item, expirationDate) in self.timeTable {
      if expirationDate < now {
        self.timeTable[item] = nil
        self.storage[item] = nil
      }
    }
    await collectGarbage()
  }
}

// MARK: - ClientCacheStorage
actor ClientCacheStorage {

  /// [AuthHeaderID: ClientCache]
  private var storage = [String: ClientCache]()
  private var noAuth = ClientCache()

  private init() {}

  static let shared = ClientCacheStorage()

  func cache(for authenticationHeader: AuthenticationHeader) -> ClientCache {
    if let id = authenticationHeader.id {
      if let cache = self.storage[id] {
        return cache
      } else {
        let cache = ClientCache()
        self.storage[id] = cache
        return cache
      }
    } else {
      return self.noAuth
    }
  }
}

extension Duration {
  fileprivate var asTimeInterval: TimeInterval {
    let comps = self.components
    let attos = Double(comps.attoseconds) / 1_000_000_000_000_000_000
    return Double(comps.seconds) + attos
  }
}
