//
//  Relationship.swift
//  PaicordLib
//
// Created by Lakhan Lothiyi on 30/08/2025.
// Copyright © 2025 Lakhan Lothiyi.
//

/// A relationship between the current user and another user.
/// https://docs.discord.food/resources/relationships#relationship-object
public struct DiscordRelationship: Sendable, Codable {

  @UnstableEnum<Int>
  public enum Kind: Sendable, Codable {
    case none  // 0
    case friend  // 1
    case blocked  // 2
    case incomingRequest  // 3
    case outgoingRequest  // 4
    case implicit  // 5
    case __undocumented(Int)

    /// Used for query params, all caps with underscores. fatalError for undocumented
    public var queryString: String {
      switch self {
      case .none: return "NONE"
      case .friend: return "FRIEND"
      case .blocked: return "BLOCKED"
      case .incomingRequest: return "INCOMING_REQUEST"
      case .outgoingRequest: return "OUTGOING_REQUEST"
      case .implicit: return "IMPLICIT"
      case .__undocumented:
        fatalError("Undocumented enum case has no string value")
      }
    }
  }

  public var id: UserSnowflake
  public var type: Kind
  public var user: PartialUser
  public var nickname: String?
  public var is_spam_request: Bool?
  public var stranger_request: Bool?
  public var user_ignored: Bool
  public var origin_application_id: ApplicationSnowflake?
  public var since: DiscordTimestamp?

  // Sent when this payload came from RelationshipAdd
  public var should_notify: Bool?
}

/// https://docs.discord.food/resources/relationships#friend-suggestion-object
public struct FriendSuggestion: Sendable, Codable {
  public var suggested_user: PartialUser
  public var reasons: [Reason]

  public struct Reason: Sendable, Codable {
    public var type: Kind
    //		public var platform: // FIXME: Needs type (string enum of services)
    public var name: String

    @UnstableEnum<UInt>
    public enum Kind: Sendable, Codable {
      case externalFriend  // 1
      case __undocumented(UInt)
    }
  }
}

public typealias FriendSuggestions = [FriendSuggestion]

/// https://docs.discord.food/resources/relationships#bulk-add-relationships
public struct BulkAddRelationshipsResult: Sendable, Codable {
  public var failed_requests: [UserSnowflake]
  public var successful_requests: [UserSnowflake]
}
