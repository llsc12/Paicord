/// https://discord.com/developers/docs/resources/application-role-connection-metadata#application-role-connection-metadata-object-application-role-connection-metadata-structure
public struct ApplicationRoleConnectionMetadata: Sendable, Codable, ValidatablePayload {

    /// https://discord.com/developers/docs/resources/application-role-connection-metadata#application-role-connection-metadata-object-application-role-connection-metadata-type
    @UnstableEnum<Int>
    public enum Kind: Sendable, Codable {
        case integerLessThanOrEqual  // 1
        case integerGreaterThanOrEqual  // 2
        case integerEqual  // 3
        case integerNotEqual  // 4
        case dateTimeLessThanOrEqual  // 5
        case dateTimeGreaterThanOrEqual  // 6
        case booleanEqual  // 7
        case booleanNotEqual  // 8
        case __undocumented(Int)
    }

    public var type: Kind
    public var key: String
    public var name: String
    public var name_localizations: DiscordLocaleDict<String>?
    public var description: String
    public var description_localizations: DiscordLocaleDict<String>?

    public init(
        type: Kind,
        key: String,
        name: String,
        name_localizations: [DiscordLocale: String]? = nil,
        description: String,
        description_localizations: [DiscordLocale: String]? = nil
    ) {
        self.type = type
        self.key = key
        self.name = name
        self.name_localizations = .init(name_localizations)
        self.description = description
        self.description_localizations = .init(description_localizations)
    }

    public func validate() -> [ValidationFailure] {
        validateCharacterCountInRange(name, min: 1, max: 100, name: "name")
        validateCharacterCountInRange(description, min: 1, max: 200, name: "description")
    }
}
