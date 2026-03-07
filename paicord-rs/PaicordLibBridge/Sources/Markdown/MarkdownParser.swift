import DiscordMarkdownParser

func discord_markdown_parser_new() -> DiscordMarkdownParser {
    return DiscordMarkdownParser()
}

class BridgedAstDocumentNode {
    var node: AST.DocumentNode

    init(node: AST.DocumentNode) {
        self.node = node
    }

    func get_children_count() -> Int32 {
        return Int32(self.node.children.count)
    }

    func get_child(index: Int32) -> BridgedAstNode {
        return BridgedAstNode(node: self.node.children[Int(index)])
    }
}

class BridgedAstNode {
    var node: ASTNode

    init(node: ASTNode) {
        self.node = node
    }

    func get_node_type() -> String {
        self.node.nodeType.rawValue
    }

    func get_source_location() -> SourceLocationRust {
        if let loc = self.node.sourceLocation {
            return SourceLocationRust(line: Int32(loc.line), column: Int32(loc.column), offset: Int32(loc.offset))
        } else {
            return SourceLocationRust(line: -1, column: -1, offset: -1)
        }
    }

    func get_content() -> Optional<String> {
        if let node = self.node as? AST.TextNode {
            return node.content
        } else {
            return nil
        }
    }

    func get_children_count() -> Int32 {
        return Int32(self.node.children.count)
    }

    func get_child(index: Int32) -> BridgedAstNode {
        return BridgedAstNode(node: self.node.children[Int(index)])
    }
}

extension DiscordMarkdownParser {
    func parse_ast_rust(markdown: RustString) async throws(BridgedRustError) -> BridgedAstDocumentNode {
        do {
            let node = try await self.parseToAST(markdown.toString())
            return BridgedAstDocumentNode(node: node)
        } catch {
            throw BridgedRustError.UnhandledError("Failed to parse markdown: \(error.localizedDescription)".intoRustString())
        }
    }
}

extension BridgedAstNode: @unchecked Sendable {}
extension BridgedAstDocumentNode: @unchecked Sendable {}
extension SourceLocationRust: @unchecked Sendable {}