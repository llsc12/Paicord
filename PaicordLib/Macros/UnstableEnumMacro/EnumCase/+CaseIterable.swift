import SwiftSyntax

extension [EnumCase] {
    func makeCaseIterable(
        accessLevel: String,
        enumIdentifier: TokenSyntax
    ) -> DeclSyntax {
        let cases = self.map { ".\($0.key)," }
        return """
            \(raw: accessLevel)static var allCases: [\(enumIdentifier)] {
            [
            \(raw: cases.indented())
            ]
            }
            """
    }
}
