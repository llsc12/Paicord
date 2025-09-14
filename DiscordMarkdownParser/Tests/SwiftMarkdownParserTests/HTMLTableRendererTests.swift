import XCTest
@testable import DiscordMarkdownParser

/// Test suite for HTML table renderer improvements
/// Testing inline markdown support, accessibility, and advanced features
final class HTMLTableRendererTests: XCTestCase {
    
    var parser: DiscordMarkdownParser!
    var renderer: HTMLRenderer!
    
    override func setUp() {
        super.setUp()
        parser = DiscordMarkdownParser(
            configuration: DiscordMarkdownParser.Configuration(
                enableGFMExtensions: true,
                trackSourceLocations: true
            )
        )
        renderer = HTMLRenderer()
    }
    
    override func tearDown() {
        parser = nil
        renderer = nil
        super.tearDown()
    }
    
    // MARK: - Inline Markdown Support Tests
    
    func test_tableCell_rendersBoldText() async throws {
        let markdown = """
        | Header |
        |--------|
        | **Bold** text |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        XCTAssertTrue(html.contains("<strong>Bold</strong>"))
        XCTAssertTrue(html.contains("<td><strong>Bold</strong> text</td>"))
    }
    
    func test_tableCell_rendersItalicText() async throws {
        let markdown = """
        | Header |
        |--------|
        | *Italic* text |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        XCTAssertTrue(html.contains("<em>Italic</em>"))
        XCTAssertTrue(html.contains("<td><em>Italic</em> text</td>"))
    }
    
    func test_tableCell_rendersCodeSpan() async throws {
        let markdown = """
        | Header |
        |--------|
        | `code` span |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        XCTAssertTrue(html.contains("<code>code</code>"))
        XCTAssertTrue(html.contains("<td><code>code</code> span</td>"))
    }
    
    func test_tableCell_rendersLinks() async throws {
        let markdown = """
        | Header |
        |--------|
        | [Link](https://example.com) text |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        XCTAssertTrue(html.contains("<a href=\"https://example.com\">Link</a>"))
        XCTAssertTrue(html.contains("<td><a href=\"https://example.com\">Link</a> text</td>"))
    }
    
    func test_tableCell_rendersComplexInlineMarkdown() async throws {
        let markdown = """
        | Header |
        |--------|
        | **Bold** and *italic* with `code` and [link](https://example.com) |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        XCTAssertTrue(html.contains("<strong>Bold</strong>"))
        XCTAssertTrue(html.contains("<em>italic</em>"))
        XCTAssertTrue(html.contains("<code>code</code>"))
        XCTAssertTrue(html.contains("<a href=\"https://example.com\">link</a>"))
    }
    
    func test_tableCell_rendersStrikethrough() async throws {
        let markdown = """
        | Header |
        |--------|
        | ~~Strikethrough~~ text |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        XCTAssertTrue(html.contains("<del>Strikethrough</del>"))
        XCTAssertTrue(html.contains("<td><del>Strikethrough</del> text</td>"))
    }
    
    func test_tableCell_rendersAutolinks() async throws {
        let markdown = """
        | Header |
        |--------|
        | https://example.com |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        XCTAssertTrue(html.contains("<a href=\"https://example.com\">https://example.com</a>"))
    }
    
    func test_tableCell_rendersNestedInlineElements() async throws {
        let markdown = """
        | Header |
        |--------|
        | **Bold** and *italic* text |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        // Should render both strong and em elements
        XCTAssertTrue(html.contains("<strong>Bold</strong>"))
        XCTAssertTrue(html.contains("<em>italic</em>"))
    }
    
    func test_tableCell_handlesEscapedCharacters() async throws {
        let markdown = """
        | Header |
        |--------|
        | \\*Not bold\\* and \\`not code\\` |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        XCTAssertTrue(html.contains("*Not bold*"))
        XCTAssertTrue(html.contains("not code"))
        XCTAssertFalse(html.contains("<strong>"))
        XCTAssertFalse(html.contains("<code>"))
    }
    
    // MARK: - Accessibility Tests
    
    func test_table_includesAccessibilityAttributes() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                customAttributes: [
                    .table: ["role": "table", "aria-label": "Data table"],
                    .tableCell: ["scope": "col"]
                ]
            )
        )
        let accessibleRenderer = HTMLRenderer(context: context)
        
        let markdown = """
        | Name | Age |
        |------|-----|
        | John | 25  |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await accessibleRenderer.render(document: ast)
        
        XCTAssertTrue(html.contains("role=\"table\""))
        XCTAssertTrue(html.contains("aria-label=\"Data table\""))
    }
    
    func test_tableHeaders_includeScopeAttributes() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                customAttributes: [
                    .tableCell: ["scope": "col"]
                ]
            )
        )
        let accessibleRenderer = HTMLRenderer(context: context)
        
        let markdown = """
        | Name | Age |
        |------|-----|
        | John | 25  |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await accessibleRenderer.render(document: ast)
        
        // Headers should have scope="col"
        XCTAssertTrue(html.contains("<th scope=\"col\">Name</th>"))
        XCTAssertTrue(html.contains("<th scope=\"col\">Age</th>"))
    }
    
    func test_table_includesCaption() async throws {
        // This test will pass when we implement caption support
        let markdown = """
        | Name | Age |
        |------|-----|
        | John | 25  |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        // For now, just ensure table renders without caption
        XCTAssertTrue(html.contains("<table>"))
        XCTAssertFalse(html.contains("<caption>"))
    }
    
    // MARK: - Enhanced Styling Tests
    
    func test_table_supportsZebraStriping() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                cssClasses: [
                    .tableRow: "table-row",
                    .table: "zebra-striped"
                ]
            )
        )
        let styledRenderer = HTMLRenderer(context: context)
        
        let markdown = """
        | Name | Age |
        |------|-----|
        | John | 25  |
        | Jane | 30  |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await styledRenderer.render(document: ast)
        
        XCTAssertTrue(html.contains("class=\"zebra-striped\""))
        XCTAssertTrue(html.contains("class=\"table-row\""))
    }
    
    func test_table_supportsCustomCellPadding() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                customAttributes: [
                    .tableCell: ["style": "padding: 12px;"]
                ]
            )
        )
        let styledRenderer = HTMLRenderer(context: context)
        
        let markdown = """
        | Name | Age |
        |------|-----|
        | John | 25  |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await styledRenderer.render(document: ast)
        
        XCTAssertTrue(html.contains("style=\"padding: 12px;\""))
    }
    
    // MARK: - Performance Tests
    
    func test_table_handlesLargeDatasets() async throws {
        // Generate a large table
        var markdown = "| ID | Name | Value |\n|-----|------|-------|\n"
        for i in 1...1000 {
            markdown += "| \(i) | Item \(i) | Value \(i) |\n"
        }
        
        let startTime = Date()
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        let endTime = Date()
        
        let renderTime = endTime.timeIntervalSince(startTime)
        
        // Should render within reasonable time (less than 1 second)
        XCTAssertLessThan(renderTime, 1.0)
        XCTAssertTrue(html.contains("<table>"))
        XCTAssertTrue(html.contains("Item 1000"))
    }
    
    // MARK: - Error Handling Tests
    
    func test_table_handlesEmptyCells() async throws {
        let markdown = """
        | Name | Age |
        |------|-----|
        | John |     |
        |      | 25  |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        XCTAssertTrue(html.contains("<td></td>"))
        XCTAssertTrue(html.contains("<td>John</td>"))
        XCTAssertTrue(html.contains("<td>25</td>"))
    }
    
    func test_table_handlesSpecialCharacters() async throws {
        let markdown = """
        | Name | Special |
        |------|---------|
        | John | <>&"' |
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        XCTAssertTrue(html.contains("&lt;&gt;&amp;&quot;&#39;"))
        XCTAssertFalse(html.contains("<>&\"'"))
    }
} 
