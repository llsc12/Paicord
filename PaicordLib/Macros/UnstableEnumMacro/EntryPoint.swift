import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct EntryPoint: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        UnstableEnum.self
    ]
}
