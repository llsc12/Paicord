import SwiftSyntax

extension [EnumCase] {
    func makeInitializer(
        accessLevel: String,
        rawType: RawKind
    ) -> DeclSyntax {
        let cases = self.map { enumCase in
            """
            case \(enumCase.maybeQuotedValue(rawType: rawType)):
                self = .\(enumCase.key)
            """
        }
        return #"""
            \#(raw: accessLevel)init?(rawValue: \#(raw: rawType.rawValue)) {
                switch rawValue {
            \#(raw: cases.indented())
                default:
                    self = .__undocumented(rawValue)
                }
            }
            """#
    }
}
