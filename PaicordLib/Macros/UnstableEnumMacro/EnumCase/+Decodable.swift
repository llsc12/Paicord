import SwiftSyntax
import SwiftSyntaxMacros

extension [EnumCase] {
    func makeDecodableInitializer(
        accessLevel: String,
        enumIdentifier: TokenSyntax,
        location: AbstractSourceLocation,
        rawType: RawKind
    ) -> DeclSyntax {
        #"""
        \#(raw: accessLevel)init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(\#(raw: rawType.rawValue).self)
            self.init(rawValue: rawValue)!
            #if DISCORDBM_ENABLE_LOGGING_DURING_DECODE
            if case let .__undocumented(rawValue) = self {
                DiscordGlobalConfiguration.makeDecodeLogger("\#(raw: enumIdentifier.trimmedDescription)").warning(
                    "Found an undocumented rawValue",
                    metadata: [
                        "rawValue": "\(rawValue)",
                        "typeName": "\#(raw: enumIdentifier.trimmedDescription)",
                        "location": "\#(raw: location.description)",
                    ]
                )
            }
            #endif
        }
        """#
    }
}
