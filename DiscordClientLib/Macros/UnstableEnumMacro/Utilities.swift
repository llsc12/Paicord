import SwiftSyntax
import SwiftSyntaxMacros

package func findParentTypeNames(
    from lexicalContext: [Syntax]
) throws -> String {
    try lexicalContext.map { syntax in
        switch syntax.kind {
        case .actorDecl:
            syntax.as(ActorDeclSyntax.self)!.name.trimmedDescription
        case .classDecl:
            syntax.as(ClassDeclSyntax.self)!.name.trimmedDescription
        case .enumDecl:
            syntax.as(EnumDeclSyntax.self)!.name.trimmedDescription
        case .structDecl:
            syntax.as(StructDeclSyntax.self)!.name.trimmedDescription
        case .extensionDecl:
            syntax.as(ExtensionDeclSyntax.self)!.extendedType.trimmedDescription
        default:
            throw MacroError.unexpectedSyntaxInLexicalContext
        }
    }.reversed().joined(separator: ".")
}
