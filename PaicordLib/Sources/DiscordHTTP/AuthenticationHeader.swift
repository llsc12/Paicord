import DiscordModels
import SkipFuse
import NIOHTTP1

import struct Foundation.Data

public enum AuthenticationHeader: Sendable {
  case botToken(Secret)
  case oAuthToken(Secret)
  case userToken(Secret)
  case userNone
  case none

  @inlinable
  var id: String? {
    switch self {
    case .botToken(let secret):
      return "b-\(secret.value.hash)"
    case .oAuthToken(let secret):
      return "o-\(secret.value.hash)"
    case .userToken(let secret):
      return "u-\(secret.value.hash)"
    case .userNone:
      return "u"
    case .none:
      return nil
    }
  }

  /// Adds an authentication header or throws an error.
  @inlinable
  func addHeader(headers: inout HTTPHeaders, request: DiscordHTTPRequest) throws {
    switch self {
    case .botToken(let secret):
      headers.replaceOrAdd(name: "Authorization", value: "Bot \(secret.value)")
    case .oAuthToken(let secret):
      headers.replaceOrAdd(
        name: "Authorization", value: "Bearer \(secret.value)")
    case .userToken(let secret):
      headers.replaceOrAdd(name: "Authorization", value: secret.value)
    case .userNone, .none:
      throw DiscordHTTPError.authenticationHeaderRequired(request: request)
    }
  }

  /// Extracts the app-id from a bot token. Otherwise returns nil.
  @inlinable
  func extractAppIdIfAvailable() -> ApplicationSnowflake? {
    switch self {
    case .botToken(let token):
      if let base64 = token.value.split(separator: ".").first {
        for base64 in [base64, base64 + "=="] {
          if let data = Data(base64Encoded: String(base64)),
            let decoded = String(data: data, encoding: .utf8)
          {
            return ApplicationSnowflake(decoded)
          }
        }
      }

      DiscordGlobalConfiguration.makeLogger("AuthenticationHeader").error(
        "Cannot extract app-id from the bot token, please report this at https://github.com/DiscordBM/DiscordBM/issues. It can be an empty issue with a title like 'AuthenticationHeader failed to decode app-id'",
        metadata: [
          "botTokenSecret": .stringConvertible(token)
        ]
      )
      return nil
    case .oAuthToken, .userToken, .userNone, .none: return nil
    }
  }

  @inlinable
  var userMode: Bool {
    switch self {
    case .userNone, .userToken: return true
    default: return false
    }
  }
}
