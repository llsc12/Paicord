// this file is made by hand :c

import DiscordModels
import NIOHTTP1

public enum UserAPIEndpoint: Endpoint {
  // MARK: - Authentication
  case getExperiments
  case userLogin  // requires fingerprint
  case verifySendSMS  // requires fingerprint
  case verifyMFALogin(type: Payloads.MFASubmitData.MFAKind)  // requires fingerprint
  case getAuthSessions
  case logoutAuthSessions
  case forgotPassword
  case verifyMFA

  // MARK: - Applications
  case getApplications
  case getApplicationsWithAssets
  case getApplication(id: ApplicationSnowflake)
  case getEmbeddedActivities(guildId: GuildSnowflake?)
  case getPartialApplications(ids: [ApplicationSnowflake])
  case getDetectableApplications

  // MARK: Auto Moderation
  case validateAutoModRule(guildId: GuildSnowflake)
  case executeAutoModAlertAction(guildId: GuildSnowflake)
  // ...

  // MARK: - Channels

  // MARK: - Emojis
  case getGuildTopEmojis(guildId: GuildSnowflake)

  /// This case serves as a way of discouraging exhaustive switch statements
  case __DO_NOT_USE_THIS_CASE

  var urlPrefix: String {
    "https://discord.com/api/v\(DiscordGlobalConfiguration.apiVersion)/"
  }

  public var url: String {
    let suffix: String
    switch self {
    // MARK: - Authentication
    case .getExperiments:
      suffix = "experiments"
    case .userLogin:
      suffix = "auth/login"
    case .verifySendSMS:
      suffix = "auth/mfa/sms/send"
    case .verifyMFALogin(let type):
      suffix = "auth/mfa/\(type.rawValue)"
    case .getAuthSessions:
      suffix = "auth/sessions"
    case .logoutAuthSessions:
      suffix = "auth/sessions/logout"
    case .forgotPassword:
      suffix = "auth/forgot"
    case .verifyMFA:
      suffix = "mfa/finish"

    // MARK: - Applications
    case .getApplications:
      suffix = "applications"
    case .getApplicationsWithAssets:
      suffix = "applications-with-assets"
    case .getApplication(let id):
      suffix = "applications/\(id.rawValue)"
    case .getEmbeddedActivities(let guildId):
      if let guildId {
        suffix = "activities/shelf?guild_id=\(guildId.rawValue)"
      } else {
        suffix = "activities/shelf"
      }
    case .getPartialApplications(let ids):
      let idsString = ids.map(\.rawValue).joined(separator: ",")
      suffix = "applications/public?application_ids=\(idsString)"
    case .getDetectableApplications:
      suffix = "applications/detectable"

    // MARK: - Auto Moderation
    case .validateAutoModRule(let guildId):
      suffix = "guilds/\(guildId.rawValue)/auto-moderation/rules/validate"
    case .executeAutoModAlertAction(let guildId):
      suffix = "guilds/\(guildId.rawValue)/auto-moderation/alert-action"
    case .getGuildTopEmojis(let guildId):
      suffix = "/guilds/\(guildId.rawValue)/top-emojis"
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }

    return urlPrefix + suffix
  }

  public var urlDescription: String {
    let suffix: String
    switch self {
    case .getExperiments:
      suffix = "experiments"
    case .userLogin:
      suffix = "auth/login"
    case .verifySendSMS:
      suffix = "auth/mfa/sms/send"
    case .verifyMFALogin(let type):
      suffix = "auth/mfa/\(type.rawValue)"
    case .getAuthSessions:
      suffix = "auth/sessions"
    case .logoutAuthSessions:
      suffix = "auth/sessions/logout"
    case .forgotPassword:
      suffix = "auth/forgot"
    case .verifyMFA:
      suffix = "mfa/finish"
    case .getApplications:
      suffix = "applications"
    case .getApplicationsWithAssets:
      suffix = "applications-with-assets"
    case .getApplication(let id):
      suffix = "applications/\(id.rawValue)"
    case .getEmbeddedActivities(let guildId):
      if let guildId {
        suffix = "activities/shelf?guild_id=\(guildId.rawValue)"
      } else {
        suffix = "activities/shelf"
      }
    case .getPartialApplications(let ids):
      let idsString = ids.map(\.rawValue).joined(separator: ",")
      suffix = "applications/public?application_ids=\(idsString)"
    case .getDetectableApplications:
      suffix = "applications/detectable"
    case .validateAutoModRule(let guildId):
      suffix = "guilds/\(guildId.rawValue)/auto-moderation/rules/validate"
    case .executeAutoModAlertAction(let guildId):
      suffix = "guilds/\(guildId.rawValue)/auto-moderation/alert-action"
    case .getGuildTopEmojis(let guildId):
      suffix = "/guilds/\(guildId.rawValue)/top-emojis"
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }

    return self.urlPrefix + suffix
  }

  public var httpMethod: HTTPMethod {
    switch self {
    case .getExperiments:
      return .GET
    case .userLogin:
      return .POST
    case .verifySendSMS:
      return .POST
    case .verifyMFALogin:
      return .POST
    case .getAuthSessions:
      return .GET
    case .logoutAuthSessions:
      return .POST
    case .forgotPassword:
      return .POST
    case .verifyMFA:
      return .POST
    case .getApplications:
      return .GET
    case .getApplicationsWithAssets:
      return .GET
    case .getApplication:
      return .GET
    case .getEmbeddedActivities:
      return .GET
    case .getPartialApplications:
      return .GET
    case .getDetectableApplications:
      return .GET
    case .validateAutoModRule:
      return .POST
    case .executeAutoModAlertAction:
      return .POST
    case .getGuildTopEmojis:
      return .GET
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var countsAgainstGlobalRateLimit: Bool {
    switch self {
    case .getExperiments: return false
    case .userLogin: return true
    case .verifySendSMS: return true
    case .verifyMFALogin: return true
    case .getAuthSessions: return true
    case .logoutAuthSessions: return true
    case .forgotPassword: return true
    case .verifyMFA: return true
    case .getApplications: return true
    case .getApplicationsWithAssets: return true
    case .getApplication: return true
    case .getEmbeddedActivities: return true
    case .getPartialApplications: return true
    case .getDetectableApplications: return true
    case .validateAutoModRule: return true
    case .executeAutoModAlertAction: return true
    case .getGuildTopEmojis: return true
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var requiresAuthorizationHeader: Bool {
    switch self {
    case .getExperiments: return false
    case .userLogin: return false
    case .verifySendSMS: return false
    case .verifyMFALogin: return false
    case .getAuthSessions: return true
    case .logoutAuthSessions: return true
    case .forgotPassword: return false
    case .verifyMFA: return true
    case .getApplications: return true
    case .getApplicationsWithAssets: return true
    case .getApplication: return true
    case .getEmbeddedActivities: return true
    case .getPartialApplications: return true
    case .getDetectableApplications: return true
    case .validateAutoModRule: return true
    case .executeAutoModAlertAction: return true
    case .getGuildTopEmojis: return true
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var parameters: [String] {
    switch self {
    case .getExperiments: return []
    case .userLogin: return []
    case .verifySendSMS: return []
    case .verifyMFALogin(let type): return [type.rawValue]
    case .getAuthSessions: return []
    case .logoutAuthSessions: return []
    case .forgotPassword: return []
    case .verifyMFA: return []
    case .getApplications: return []
    case .getApplicationsWithAssets: return []
    case .getApplication(let id): return [id.rawValue]
    case .getEmbeddedActivities(let guildId):
      return [guildId?.rawValue].compactMap { $0 }
    case .getPartialApplications(let ids): return ids.map { $0.rawValue }
    case .getDetectableApplications: return []
    case .validateAutoModRule(let guildId): return [guildId.rawValue]
    case .executeAutoModAlertAction(let guildId): return [guildId.rawValue]
    case .getGuildTopEmojis(let guildId): return [guildId.rawValue]
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var id: Int {
    switch self {
    case .getExperiments: return 1
    case .userLogin: return 2
    case .verifySendSMS: return 3
    case .verifyMFALogin: return 4
    case .getAuthSessions: return 5
    case .logoutAuthSessions: return 6
    case .forgotPassword: return 7
    case .verifyMFA: return 8
    case .getApplications: return 9
    case .getApplicationsWithAssets: return 10
    case .getApplication: return 11
    case .getEmbeddedActivities: return 12
    case .getPartialApplications: return 13
    case .getDetectableApplications: return 14
    case .validateAutoModRule: return 15
    case .executeAutoModAlertAction: return 16
    // ... space for ignored endpoints i didn't implement
    case .getGuildTopEmojis: return 41
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var description: String {
    switch self {
    case .getExperiments: return "getExperiments"
    case .userLogin: return "userLoginCredentials"
    case .verifySendSMS: return "verifySendSMS"
    case .verifyMFALogin(let type):
      return "verifyMFALogin(type.rawValue: \(type.rawValue))"
    case .getAuthSessions: return "getAuthSessions"
    case .logoutAuthSessions: return "logoutAuthSessions"
    case .forgotPassword: return "forgotPassword"
    case .verifyMFA: return "verifyMFA"
    case .getApplications: return "getApplications"
    case .getApplicationsWithAssets: return "getApplicationsWithAssets"
    case .getApplication(let id): return "getApplication(id: \(id.rawValue))"
    case .getEmbeddedActivities(let guildId):
      if let guildId {
        return "getEmbeddedActivities(guildId: \(guildId.rawValue))"
      } else {
        return "getEmbeddedActivities(guildId: nil)"
      }
    case .getPartialApplications(let ids):
      let idsString = ids.map(\.rawValue).joined(separator: ",")
      return "getPartialApplications(ids: [\(idsString)])"
    case .getDetectableApplications: return "getDetectableApplications"
    case .validateAutoModRule(let guildId):
      return "validateAutoModRule(guildId: \(guildId.rawValue), ...)"
    case .executeAutoModAlertAction(let guildId):
      return "executeAutoModAlertAction(guildId: \(guildId.rawValue), ..."
    case .getGuildTopEmojis(let guildId):
      return "getGuildTopEmojis(guildId: \(guildId.rawValue))"
    case .__DO_NOT_USE_THIS_CASE:
      fatalError(
        "If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
      )
    }
  }

  public var specialisedRatelimit: (maxRequests: Int, for: Duration)? {
    switch self {
    default: return nil
    }
  }
}
