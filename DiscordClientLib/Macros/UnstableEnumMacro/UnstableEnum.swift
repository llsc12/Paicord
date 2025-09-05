import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// A macro to stabilize enums that might get more cases, to some extent.
/// The main goal is to not fail json decodings if Discord adds a new case.
///
/// This is supposed to be used with enums that are supposed to be raw-representable.
/// The macro accepts one and only one of these types as a generic argument:
/// `String`, `Int`, `UInt`. More types can be added on demand.
/// The generic argument represents the `RawValue` of a `RawRepresentable` type.
/// You can manually declare the raw value of a case, using a comment in front of it like so:
/// ```swift
/// case something // "actually nothing!"
/// case anything // still nothing!
///
/// case value12 // 12
/// ```
///
/// Requires you to add a new `.__undocumented(RawValue)` case as the last case.
/// How it manipulates the code:
/// Adds `RawRepresentable` conformance where `RawValue` is the generic argument of the macro.
/// which can too easily result in code breakage.
/// If `Decodable`, adds a slightly-modified `init(from:)` initializer.
/// If `CaseIterable`, repairs the `static var allCases` requirement.
public struct UnstableEnum: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if declaration.hasError { return [] }

        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw MacroError.isNotEnum
        }
        let accessLevel = enumDecl.accessLevelModifier.map { "\($0) " } ?? ""

        guard let name = node.attributeName.as(IdentifierTypeSyntax.self),
            let generic = name.genericArgumentClause,
            generic.arguments.count == 1,
            let genericTypeSyntax = generic.arguments.first?.argument,
            let genericType = genericTypeSyntax.as(IdentifierTypeSyntax.self)
        else {
            throw MacroError.macroDoesNotHaveRequiredGenericArgument
        }

        guard let rawType = RawKind(rawValue: genericType.name.trimmedDescription) else {
            throw MacroError.unexpectedGenericArgument
        }

        let members = enumDecl.memberBlock.members
        let caseDecls = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let elements = caseDecls.flatMap { $0.elements }

        let (cases, hasError) = elements.makeCases(rawType: rawType, context: context)

        if hasError { return [] }

        /// Some validations

        let values = cases.map(\.value)

        if values.isEmpty { return [] }

        /// All values must be unique
        if Set(values).count != values.count {
            throw MacroError.valuesMustBeUnique
        }

        switch rawType {
        case .String:
            /// All values must be string
            if values.allSatisfy({ Int($0) != nil }) {
                throw MacroError.enumSeemsToHaveIntValuesButGenericArgumentSpecifiesString
            }
        case .Int, .UInt:
            /// All values must be integer
            if !values.allSatisfy({ Int($0.filter({ $0 != "_" })) != nil }) {
                throw MacroError.intEnumMustOnlyHaveIntValues
            }
        }

        var syntaxes: [DeclSyntax] = [
            cases.makeRawValueVar(accessLevel: accessLevel, rawType: rawType),
            cases.makeInitializer(accessLevel: accessLevel, rawType: rawType),
        ]

        let conformsToCaseIterable = enumDecl.inheritanceClause?.inheritedTypes.contains {
            $0.type.as(IdentifierTypeSyntax.self)?.name.trimmedDescription == "CaseIterable"
        }

        if conformsToCaseIterable == true {
            let conformance = cases.makeCaseIterable(
                accessLevel: accessLevel,
                enumIdentifier: enumDecl.name
            )
            syntaxes.append(conformance)
        }

        let conformsToDecodable = enumDecl.inheritanceClause?.inheritedTypes.contains {
            let name = $0.type.as(IdentifierTypeSyntax.self)?.name.trimmedDescription
            return name == "Codable" || name == "Decodable"
        }

        if conformsToDecodable == true {
            guard let location: AbstractSourceLocation = context.location(of: node) else {
                throw MacroError.couldNotFindLocationOfNode
            }
            let decodableInit = cases.makeDecodableInitializer(
                accessLevel: accessLevel,
                enumIdentifier: enumDecl.name,
                location: location,
                rawType: rawType
            )
            syntaxes.append(decodableInit)
        }

        return syntaxes
    }
}

extension UnstableEnum: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        if declaration.hasError { return [] }

        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw MacroError.isNotEnum
        }

        let parentNames = try findParentTypeNames(from: context.lexicalContext)
        let enumName = enumDecl.name.trimmedDescription
        let qualifiedName = parentNames.isEmpty ? enumName : parentNames + "." + enumName
        let syntax: DeclSyntax = """
            extension \(raw: qualifiedName): RawRepresentable, LosslessRawRepresentable, Hashable { }
            """
        let ext = ExtensionDeclSyntax(syntax)!

        return [ext]
    }
}

extension EnumDeclSyntax {
    fileprivate var accessLevelModifier: String? {
        let accessLevelModifiers: [Keyword] = [.open, .public, .package, .internal, .private, .fileprivate]
        for modifier in self.modifiers {
            guard case let .keyword(keyword) = modifier.name.tokenKind else {
                continue
            }
            if accessLevelModifiers.contains(keyword) {
                return modifier.name.trimmedDescription
            }
        }
        return nil
    }
}
