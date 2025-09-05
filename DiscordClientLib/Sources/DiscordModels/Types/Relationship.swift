//
//  Relationship.swift
//  DiscordClientLib
//
//  Created by Lakhan Lothiyi on 30/08/2025.
//

/// A relationship between the current user and another user.
/// https://docs.discord.food/resources/relationships#relationship-object
public struct DiscordRelationship: Sendable, Codable {
	
	/// https://discord.com/developers/docs/resources/poll#layout-type
	@UnstableEnum<Int>
	public enum RelationshipType: Sendable, Codable {
			case none  // 0
		case friend // 1
		case blocked // 2
		case incomingRequest // 3
		case outgoingRequest // 4
		case implicit // 5
			case __undocumented(Int)
	}
	
	public var id: UserSnowflake
	public var type: RelationshipType
	public var user: PartialUser
	public var nickname: String?
	public var is_spam_request: Bool?
	public var stranger_request: Bool?
	public var origin_application_id: ApplicationSnowflake?
	public var since: DiscordTimestamp
}
