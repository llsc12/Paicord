import SwiftSyntax

extension [EnumCase] {
    func makeRawValueVar(
        accessLevel: String,
        rawType: RawKind
    ) -> DeclSyntax {
        let cases = self.map { enumCase in
            """
            case .\(enumCase.key):
                return \(enumCase.maybeQuotedValue(rawType: rawType))
            """
        }
        return #"""
            \#(raw: accessLevel)var rawValue: \#(raw: rawType.rawValue) {
                switch self {
            \#(raw: cases.indented())
                case let .__undocumented(rawValue):
                    return rawValue
                }
            }
            """#
    }
}
