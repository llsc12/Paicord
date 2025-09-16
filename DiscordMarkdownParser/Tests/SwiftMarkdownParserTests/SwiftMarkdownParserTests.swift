import XCTest
@testable import DiscordMarkdownParser

/// Test suite for the DiscordMarkdownParser functionality.
/// 
/// This test suite covers the AST-focused parsing functionality,
/// including parsing various markdown elements and error handling.
final class DiscordMarkdownParserTests: XCTestCase {
    var parser: DiscordMarkdownParser!
    
    override func setUp() {
        super.setUp()
        parser = DiscordMarkdownParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    // MARK: - Parser Tests
    
    func test_parse_emptyString_returnsEmptyDocument() async throws {
        let document = try await parser.parseToAST("")
        XCTAssertEqual(document.children.count, 0)
    }
    
    func test_parse_simpleParagraph_returnsDocumentWithParagraph() async throws {
        let document = try await parser.parseToAST("This is a simple paragraph.")
        XCTAssertEqual(document.children.count, 1)
        XCTAssertEqual(document.children.first?.nodeType, .paragraph)
    }
    
    // MARK: - HTML Renderer Tests
    
    func test_htmlRenderer_renderTextNode_returnsEscapedHTML() async throws {
        let renderer = HTMLRenderer()
        let textNode = AST.TextNode(content: "Hello & <world>")
        let html = try await renderer.render(node: textNode)
        XCTAssertEqual(html, "Hello &amp; &lt;world&gt;")
    }
    
    func test_htmlRenderer_renderParagraphNode_returnsWrappedHTML() async throws {
        let renderer = HTMLRenderer()
        let textNode = AST.TextNode(content: "Hello, World!")
        let paragraph = AST.ParagraphNode(children: [textNode])
        let html = try await renderer.render(node: paragraph)
        XCTAssertTrue(html.contains("<p>Hello, World!</p>"))
    }
    
    func test_htmlRenderer_renderHeadingNode_returnsHeadingHTML() async throws {
        let renderer = HTMLRenderer()
        let textNode = AST.TextNode(content: "Test Heading")
        let heading = AST.HeadingNode(level: 2, children: [textNode])
        let html = try await renderer.render(node: heading)
        XCTAssertTrue(html.contains("<h2>Test Heading</h2>"))
    }
    
    func test_htmlRenderer_renderLinkNode_returnsLinkHTML() async throws {
        let renderer = HTMLRenderer()
        let textNode = AST.TextNode(content: "Swift")
        let link = AST.LinkNode(url: "https://swift.org", title: "Swift.org", children: [textNode])
        let html = try await renderer.render(node: link)
        XCTAssertEqual(html, "<a href=\"https://swift.org\" title=\"Swift.org\">Swift</a>")
    }
    
    // MARK: - GFM Tests
    
    func test_gfm_parseSimpleTableLine() async throws {
        print("[TEST] Starting simple table line test...")
        
        let markdown = "| Name | Age |"
        
        print("[TEST] Markdown input: '\(markdown)'")
        print("[TEST] Calling parseToAST...")
        
        let ast = try await parser.parseToAST(markdown)
        
        print("[TEST] Parse completed! Children count: \(ast.children.count)")
        print("[TEST] First child type: \(type(of: ast.children.first!))")
        
        // This should still be parsed as a paragraph (single line can't be a table without separator)
        XCTAssertTrue(ast.children.first is AST.ParagraphNode)
    }
    
    func test_gfm_parseMinimalTable() async throws {
        print("[TEST] Starting minimal table test...")
        
        // For now, test that we can parse a single line without hanging
        let markdown = "| A | B |"
        
        print("[TEST] Markdown input: '\(markdown)'")
        print("[TEST] Calling parseToAST...")
        
        let ast = try await parser.parseToAST(markdown)
        
        print("[TEST] Parse completed! Children count: \(ast.children.count)")
        print("[TEST] First child type: \(type(of: ast.children.first!))")
        
        // This should be parsed as a paragraph (single line can't be a table)
        XCTAssertTrue(ast.children.first is AST.ParagraphNode)
    }
    
    func test_gfm_parseTable() async throws {
        print("[TEST] Starting table parsing test...")
        
        let markdown = """
        | Name | Age | City |
        |------|-----|------|
        | John | 25  | NYC  |
        | Jane | 30  | LA   |
        """
        
        print("[TEST] Markdown input: '\(markdown)'")
        
        let parser = DiscordMarkdownParser()
        print("[TEST] Calling parseToAST...")
        let document = try await parser.parseToAST(markdown)
        print("[TEST] Parse completed! Children count: \(document.children.count)")
        
        // Should have one table
        XCTAssertEqual(document.children.count, 1)
        
        guard let table = document.children.first as? AST.GFMTableNode else {
            XCTFail("Expected GFMTableNode, got \(type(of: document.children.first))")
            return
        }
        
        print("[TEST] Found table with \(table.rows.count) rows")
        
        // Should have 3 rows (header + 2 data rows)
        XCTAssertEqual(table.rows.count, 3)
        
        // Check header row
        let headerRow = table.rows[0]
        XCTAssertTrue(headerRow.isHeader)
        XCTAssertEqual(headerRow.cells.count, 3)
        XCTAssertEqual(headerRow.cells[0].content, "Name")
        XCTAssertEqual(headerRow.cells[1].content, "Age")
        XCTAssertEqual(headerRow.cells[2].content, "City")
        
        // Check data rows
        let dataRow1 = table.rows[1]
        XCTAssertFalse(dataRow1.isHeader)
        XCTAssertEqual(dataRow1.cells.count, 3)
        XCTAssertEqual(dataRow1.cells[0].content, "John")
        XCTAssertEqual(dataRow1.cells[1].content, "25")
        XCTAssertEqual(dataRow1.cells[2].content, "NYC")
        
        let dataRow2 = table.rows[2]
        XCTAssertFalse(dataRow2.isHeader)
        XCTAssertEqual(dataRow2.cells.count, 3)
        XCTAssertEqual(dataRow2.cells[0].content, "Jane")
        XCTAssertEqual(dataRow2.cells[1].content, "30")
        XCTAssertEqual(dataRow2.cells[2].content, "LA")
        
        // Check alignments
        XCTAssertEqual(table.alignments.count, 3)
        XCTAssertEqual(table.alignments[0], .none)
        XCTAssertEqual(table.alignments[1], .none)
        XCTAssertEqual(table.alignments[2], .none)
        
        print("[TEST] Table parsing test completed successfully!")
    }
    
    func test_gfm_parseTaskList() async throws {
        // Test single task list item
        let markdown = "- [x] Completed task"
        
        let ast = try await parser.parseToAST(markdown)
        
        guard let list = ast.children.first as? AST.ListNode else {
            XCTFail("Expected ListNode")
            return
        }
        
        XCTAssertEqual(list.items.count, 1)
        
        // Check that the item was converted to a GFMTaskListItemNode
        guard let taskItem = list.items[0] as? AST.GFMTaskListItemNode else {
            XCTFail("Expected GFMTaskListItemNode")
            return
        }
        
        XCTAssertTrue(taskItem.isChecked)
        
        // Test unchecked task
        let markdown2 = "- [ ] Incomplete task"
        let ast2 = try await parser.parseToAST(markdown2)
        
        guard let list2 = ast2.children.first as? AST.ListNode else {
            XCTFail("Expected ListNode for second test")
            return
        }
        
        guard let taskItem2 = list2.items[0] as? AST.GFMTaskListItemNode else {
            XCTFail("Expected GFMTaskListItemNode for second test")
            return
        }
        
        XCTAssertFalse(taskItem2.isChecked)
    }

    func test_gfm_parseStrikethrough() async throws {
        let markdown = "This is ~~strikethrough~~ text."
        let ast = try await parser.parseToAST(markdown)
        
        guard let paragraph = ast.children.first as? AST.ParagraphNode else {
            XCTFail("Expected ParagraphNode")
            return
        }
        
        // Should have 7 nodes: "This", " ", "is", " ", StrikethroughNode, " ", "text."
        XCTAssertEqual(paragraph.children.count, 7)
        
        // Check that the 5th node (index 4) is a strikethrough node
        let strikethroughNode = paragraph.children[4]
        XCTAssertEqual(strikethroughNode.nodeType, .strikethrough)
        
        // Verify it's actually a StrikethroughNode with correct content
        guard let strikethrough = strikethroughNode as? AST.StrikethroughNode else {
            XCTFail("Expected StrikethroughNode")
            return
        }
        
        XCTAssertEqual(strikethrough.content.count, 1)
        guard let strikethroughText = strikethrough.content.first as? AST.TextNode else {
            XCTFail("Expected TextNode in strikethrough content")
            return
        }
        XCTAssertEqual(strikethroughText.content, "strikethrough")
    }

    func test_gfm_parseAutolinks() async throws {
        let markdown = "Visit https://example.com"
        let ast = try await parser.parseToAST(markdown)
        guard let paragraph = ast.children.first as? AST.ParagraphNode else {
            XCTFail("Expected ParagraphNode")
            return
        }
        
        // Should have 3 nodes: "Visit", " ", AutolinkNode
        XCTAssertEqual(paragraph.children.count, 3)
        
        // Check that the third node is an autolink
        let autolinkNode = paragraph.children[2]
        XCTAssertEqual(autolinkNode.nodeType, .autolink)
        
        // Verify it's actually an AutolinkNode with correct content
        guard let autolink = autolinkNode as? AST.AutolinkNode else {
            XCTFail("Expected AutolinkNode")
            return
        }
        
        XCTAssertEqual(autolink.url, "https://example.com")
        XCTAssertEqual(autolink.text, "https://example.com")
    }
    
    // MARK: - List Tests
    
    func test_parseMultipleListItems_unordered() async throws {
        let markdown = """
        - Item 1
        - Item 2
        - Item 3
        """
        
        let ast = try await parser.parseToAST(markdown)
        
        XCTAssertEqual(ast.children.count, 1)
        guard let list = ast.children.first as? AST.ListNode else {
            XCTFail("Expected ListNode")
            return
        }
        
        XCTAssertFalse(list.isOrdered)
        XCTAssertEqual(list.items.count, 3)
        
        // Verify each item
        for (index, item) in list.items.enumerated() {
            guard let listItem = item as? AST.ListItemNode else {
                XCTFail("Expected ListItemNode at index \(index)")
                continue
            }
            XCTAssertEqual(listItem.children.count, 1)
            
            guard let paragraph = listItem.children.first as? AST.ParagraphNode else {
                XCTFail("Expected ParagraphNode in list item at index \(index)")
                continue
            }
            
            // Each paragraph should contain text nodes with "Item N"
            let textContent = paragraph.children.compactMap { ($0 as? AST.TextNode)?.content }.joined()
            XCTAssertEqual(textContent, "Item \(index + 1)")
        }
    }
    
    func test_parseMultipleListItems_ordered() async throws {
        let markdown = """
        1. First item
        2. Second item
        3. Third item
        """
        
        let ast = try await parser.parseToAST(markdown)
        
        XCTAssertEqual(ast.children.count, 1)
        guard let list = ast.children.first as? AST.ListNode else {
            XCTFail("Expected ListNode")
            return
        }
        
        XCTAssertTrue(list.isOrdered)
        XCTAssertEqual(list.startNumber, 1)
        XCTAssertEqual(list.items.count, 3)
        
        // Verify first item content
        guard let firstItem = list.items.first as? AST.ListItemNode,
              let paragraph = firstItem.children.first as? AST.ParagraphNode else {
            XCTFail("Expected ListItemNode with ParagraphNode")
            return
        }
        
        let textContent = paragraph.children.compactMap { ($0 as? AST.TextNode)?.content }.joined()
        XCTAssertEqual(textContent, "First item")
    }

    func test_debug_pipeCharacter() async throws {
        print("[DEBUG] Starting pipe character test...")
        
        // Test with just pipe characters to see if that's the trigger
        let markdown = "| A |"
        
        print("[DEBUG] Markdown: '\(markdown)'")
        print("[DEBUG] About to call parseToAST...")
        
        let startTime = Date()
        let result = try await parser.parseToAST(markdown)
        let endTime = Date()
        
        print("[DEBUG] Parse completed in \(endTime.timeIntervalSince(startTime)) seconds")
        print("[DEBUG] Children: \(result.children.count)")
        
        XCTAssertTrue(result.children.count >= 0)
    }

    func test_debug_simpleText() async throws {
        print("[DEBUG] Starting simple text test...")
        
        // Test with just simple text that should not trigger table parsing
        let markdown = "Hello world"
        
        print("[DEBUG] Markdown: '\(markdown)'")
        print("[DEBUG] About to call parseToAST...")
        
        let startTime = Date()
        let result = try await parser.parseToAST(markdown)
        let endTime = Date()
        
        print("[DEBUG] Parse completed in \(endTime.timeIntervalSince(startTime)) seconds")
        print("[DEBUG] Children: \(result.children.count)")
        
        XCTAssertEqual(result.children.count, 1)
        XCTAssertTrue(result.children.first is AST.ParagraphNode)
    }

    func test_debug_tableHang() async throws {
        print("[DEBUG] Starting minimal table debug test...")
        
        // Start with the simplest possible table
        let markdown = """
        | A |
        |---|
        | B |
        """
        
        print("[DEBUG] Markdown: '\(markdown)'")
        print("[DEBUG] About to call parseToAST...")
        
        // Create a simple task that we can monitor
        let startTime = Date()
        let result = try await parser.parseToAST(markdown)
        let endTime = Date()
        
        print("[DEBUG] Parse completed in \(endTime.timeIntervalSince(startTime)) seconds")
        print("[DEBUG] Children: \(result.children.count)")
        
        // If we get here, it didn't hang
        XCTAssertTrue(result.children.count >= 0)
    }

    func test_debug_tableStructure() async throws {
        print("[DEBUG] Starting table structure test...")
        
        // Test with the exact table structure that was hanging
        let markdown = """
        | A |
        |---|
        | B |
        """
        
        print("[DEBUG] Markdown: '\(markdown)'")
        print("[DEBUG] About to call parseToAST...")
        
        let startTime = Date()
        let result = try await parser.parseToAST(markdown)
        let endTime = Date()
        
        print("[DEBUG] Parse completed in \(endTime.timeIntervalSince(startTime)) seconds")
        print("[DEBUG] Children: \(result.children.count)")
        
        // Since table parsing is disabled, this should be parsed as paragraphs
        XCTAssertTrue(result.children.count >= 1)
    }

    func test_debug_tokenizerOnly() async throws {
        print("[DEBUG] Starting tokenizer-only test...")
        
        let markdown = """
        | A |
        |---|
        | B |
        """
        
        print("[DEBUG] About to create tokenizer...")
        let tokenizer = MarkdownTokenizer(markdown)
        print("[DEBUG] About to tokenize...")
        let tokens = tokenizer.tokenize()
        print("[DEBUG] Tokenization completed! Got \(tokens.count) tokens")
        
        XCTAssertTrue(tokens.count > 0)
    }

    func test_tokenizer_edge_cases() {
        // Test edge cases that previously caused infinite loops
        
        // Test mixed pipes and dashes (table separator line)
        let mixed = "|----------|----------|"
        let tokenizer = MarkdownTokenizer(mixed)
        let tokens = tokenizer.tokenize()
        
        XCTAssertGreaterThan(tokens.count, 0, "Mixed pipes and dashes should produce tokens")
        XCTAssertTrue(tokens.contains { $0.type == .pipe }, "Should contain pipe tokens")
        XCTAssertTrue(tokens.contains { $0.type == .text }, "Should contain text tokens")
    }
    
    // MARK: - GFMTableCellNode Fix Tests
    
    func test_gfmTableCellNode_nestedInlineContentExtraction() {
        // Test that the fix correctly extracts plain text from nested inline elements
        
        // Create some nested inline elements
        let boldText = AST.BoldNode(children: [
            AST.TextNode(content: "Bold")
        ])
        
        let regularText = AST.TextNode(content: " text ")
        
        let emphasisText = AST.ItalicNode(children: [
            AST.TextNode(content: "italic")
        ])
        
        let linkText = AST.LinkNode(
            url: "https://example.com",
            title: "Example",
            children: [AST.TextNode(content: "link")]
        )
        
        let codeSpan = AST.CodeSpanNode(content: "code")
        
        // Create a table cell with nested inline elements
        let tableCell = AST.GFMTableCellNode(
            children: [boldText, regularText, emphasisText, linkText, codeSpan],
            isHeader: false,
            alignment: .none
        )
        
        // Test that the content extraction works correctly
        let expectedContent = "Bold text italiclinkcode"
        let actualContent = tableCell.content
        
        XCTAssertEqual(actualContent, expectedContent, "Content extraction should work for nested inline elements")
        
        // Test that children are preserved
        XCTAssertEqual(tableCell.children.count, 5, "Children should be preserved correctly")
        
        // Test that the cell properties are correct
        XCTAssertFalse(tableCell.isHeader, "Header flag should be preserved")
        XCTAssertEqual(tableCell.alignment, .none, "Alignment should be preserved")
    }
    
    func test_gfmTableCellNode_emptyChildren() {
        // Test with empty children array
        let tableCell = AST.GFMTableCellNode(
            children: [],
            isHeader: true,
            alignment: .center
        )
        
        XCTAssertEqual(tableCell.content, "", "Empty children should result in empty content")
        XCTAssertEqual(tableCell.children.count, 0, "Children should be empty")
        XCTAssertTrue(tableCell.isHeader, "Header flag should be preserved")
        XCTAssertEqual(tableCell.alignment, .center, "Alignment should be preserved")
    }
    
    func test_gfmTableCellNode_deeplyNestedContent() {
        // Test with deeply nested content
        let deeplyNestedText = AST.ItalicNode(children: [
            AST.BoldNode(children: [
                AST.TextNode(content: "Deep")
            ])
        ])
        
        let tableCell = AST.GFMTableCellNode(
            children: [deeplyNestedText],
            isHeader: false,
            alignment: .left
        )
        
        XCTAssertEqual(tableCell.content, "Deep", "Deeply nested content should be extracted")
        XCTAssertEqual(tableCell.children.count, 1, "Children should be preserved")
    }
    
    func test_gfmTableCellNode_mixedContentTypes() {
        // Test with various content types
        let imageNode = AST.ImageNode(url: "image.jpg", altText: "Alt text")
        let autolinkNode = AST.AutolinkNode(url: "https://example.com", text: "example.com")
        let htmlInlineNode = AST.HTMLInlineNode(content: "<span>HTML</span>")
        
        let tableCell = AST.GFMTableCellNode(
            children: [imageNode, autolinkNode, htmlInlineNode],
            isHeader: false,
            alignment: .right
        )
        
        let expectedContent = "Alt textexample.com<span>HTML</span>"
        XCTAssertEqual(tableCell.content, expectedContent, "Mixed content types should be extracted correctly")
    }
}
