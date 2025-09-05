// this file is made by hand :c

import DiscordModels
import NIOHTTP1

public enum UserAPIEndpoint: Endpoint {
  case getExperiments
  case userLogin  // requires fingerprint
  case verifySendSMS  // requires fingerprint
  case verifyMFALogin(type: Payloads.AuthenticationMFA.MFAType)  // requires fingerprint
  case getAuthSessions
  case logoutAuthSessions
  case forgotPassword
  
  /// This case serves as a way of discouraging exhaustive switch statements
  case __DO_NOT_USE_THIS_CASE

  var urlPrefix: String {
    "https://discord.com/api/v\(DiscordGlobalConfiguration.apiVersion)/"
  }

  public var url: String {
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
	case .verifyMFALogin(let type): return "verifyMFALogin(type.rawValue: \(type.rawValue))"
	case .getAuthSessions: return "getAuthSessions"
	case .logoutAuthSessions: return "logoutAuthSessions"
	case .forgotPassword: return "forgotPassword"
	case .__DO_NOT_USE_THIS_CASE:
	  fatalError(
		"If the case name wasn't already clear enough: '__DO_NOT_USE_THIS_CASE' MUST NOT be used"
	  )
	}
  }
}
