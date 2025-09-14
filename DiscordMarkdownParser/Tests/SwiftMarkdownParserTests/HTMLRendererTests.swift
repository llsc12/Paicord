import XCTest
@testable import DiscordMarkdownParser

/// Comprehensive test suite for HTMLRenderer functionality.
/// 
/// This test suite covers all aspects of HTML rendering including:
/// - Basic CommonMark elements
/// - GFM extensions (tables, strikethrough, task lists)
/// - Security features (sanitization, URL validation)
/// - Custom styling and CSS classes
/// - Edge cases and error handling
final class HTMLRendererTests: XCTestCase {
    
    var renderer: HTMLRenderer!
    var parser: DiscordMarkdownParser!
    
    override func setUp() {
        super.setUp()
        renderer = HTMLRenderer()
        parser = DiscordMarkdownParser()
    }
    
    override func tearDown() {
        renderer = nil
        parser = nil
        super.tearDown()
    }
    
    // MARK: - Basic HTML Elements Tests
    
    func test_renderTextNode_escapeHTMLCharacters() async throws {
        let textNode = AST.TextNode(content: "Hello & <world> \"quoted\" 'text'")
        let html = try await renderer.render(node: textNode)
        XCTAssertEqual(html, "Hello &amp; &lt;world&gt; &quot;quoted&quot; &#39;text&#39;")
    }
    
    func test_renderTextNode_emptyString() async throws {
        let textNode = AST.TextNode(content: "")
        let html = try await renderer.render(node: textNode)
        XCTAssertEqual(html, "")
    }
    
    func test_renderTextNode_specialCharacters() async throws {
        let textNode = AST.TextNode(content: "© ® ™ € £ ¥")
        let html = try await renderer.render(node: textNode)
        XCTAssertEqual(html, "© ® ™ € £ ¥")
    }
    
    func test_renderParagraphNode_basicParagraph() async throws {
        let textNode = AST.TextNode(content: "This is a paragraph.")
        let paragraph = AST.ParagraphNode(children: [textNode])
        let html = try await renderer.render(node: paragraph)
        XCTAssertEqual(html, "<p>This is a paragraph.</p>\n")
    }
    
    func test_renderParagraphNode_multipleChildren() async throws {
        let children: [ASTNode] = [
            AST.TextNode(content: "Hello "),
            AST.ItalicNode(children: [AST.TextNode(content: "world")]),
            AST.TextNode(content: "!")
        ]
        let paragraph = AST.ParagraphNode(children: children)
        let html = try await renderer.render(node: paragraph)
        XCTAssertEqual(html, "<p>Hello <em>world</em>!</p>\n")
    }
    
    func test_renderParagraphNode_empty() async throws {
        let paragraph = AST.ParagraphNode(children: [])
        let html = try await renderer.render(node: paragraph)
        XCTAssertEqual(html, "<p></p>\n")
    }
    
    func test_renderHeadingNode_allLevels() async throws {
        for level in 1...6 {
            let textNode = AST.TextNode(content: "Heading \(level)")
            let heading = AST.HeadingNode(level: level, children: [textNode])
            let html = try await renderer.render(node: heading)
            XCTAssertEqual(html, "<h\(level)>Heading \(level)</h\(level)>\n")
        }
    }
    
    func test_renderHeadingNode_withInlineElements() async throws {
        let children: [ASTNode] = [
            AST.TextNode(content: "Bold "),
            AST.BoldNode(children: [AST.TextNode(content: "heading")]),
            AST.TextNode(content: " with "),
            AST.CodeSpanNode(content: "code")
        ]
        let heading = AST.HeadingNode(level: 2, children: children)
        let html = try await renderer.render(node: heading)
        XCTAssertEqual(html, "<h2>Bold <strong>heading</strong> with <code>code</code></h2>\n")
    }
    
    // MARK: - Emphasis and Strong Tests
    
    func test_renderEmphasisNode_basicEmphasis() async throws {
        let textNode = AST.TextNode(content: "emphasized")
        let emphasis = AST.ItalicNode(children: [textNode])
        let html = try await renderer.render(node: emphasis)
        XCTAssertEqual(html, "<em>emphasized</em>")
    }
    
    func test_renderEmphasisNode_nestedElements() async throws {
        let children: [ASTNode] = [
            AST.TextNode(content: "italic with "),
            AST.BoldNode(children: [AST.TextNode(content: "bold")])
        ]
        let emphasis = AST.ItalicNode(children: children)
        let html = try await renderer.render(node: emphasis)
        XCTAssertEqual(html, "<em>italic with <strong>bold</strong></em>")
    }
    
    func test_renderStrongEmphasisNode_basicStrong() async throws {
        let textNode = AST.TextNode(content: "strong")
        let strong = AST.BoldNode(children: [textNode])
        let html = try await renderer.render(node: strong)
        XCTAssertEqual(html, "<strong>strong</strong>")
    }
    
    func test_renderStrongEmphasisNode_nestedElements() async throws {
        let children: [ASTNode] = [
            AST.TextNode(content: "bold with "),
            AST.ItalicNode(children: [AST.TextNode(content: "italic")])
        ]
        let strong = AST.BoldNode(children: children)
        let html = try await renderer.render(node: strong)
        XCTAssertEqual(html, "<strong>bold with <em>italic</em></strong>")
    }
    
    // MARK: - Link and Image Tests
    
    func test_renderLinkNode_basicLink() async throws {
        let textNode = AST.TextNode(content: "Swift")
        let link = AST.LinkNode(url: "https://swift.org", title: nil, children: [textNode])
        let html = try await renderer.render(node: link)
        XCTAssertEqual(html, "<a href=\"https://swift.org\">Swift</a>")
    }
    
    func test_renderLinkNode_withTitle() async throws {
        let textNode = AST.TextNode(content: "Swift")
        let link = AST.LinkNode(url: "https://swift.org", title: "Swift Programming Language", children: [textNode])
        let html = try await renderer.render(node: link)
        XCTAssertEqual(html, "<a href=\"https://swift.org\" title=\"Swift Programming Language\">Swift</a>")
    }
    
    func test_renderLinkNode_complexContent() async throws {
        let children: [ASTNode] = [
            AST.TextNode(content: "Visit "),
            AST.BoldNode(children: [AST.TextNode(content: "Swift.org")])
        ]
        let link = AST.LinkNode(url: "https://swift.org", title: nil, children: children)
        let html = try await renderer.render(node: link)
        XCTAssertEqual(html, "<a href=\"https://swift.org\">Visit <strong>Swift.org</strong></a>")
    }
    
    func test_renderLinkNode_unsafeURL() async throws {
        let textNode = AST.TextNode(content: "Unsafe")
        let link = AST.LinkNode(url: "javascript:alert('xss')", title: nil, children: [textNode])
        let html = try await renderer.render(node: link)
        XCTAssertEqual(html, "Unsafe") // Should render as plain text
    }
    
    func test_renderLinkNode_dataURL() async throws {
        let textNode = AST.TextNode(content: "Data")
        let link = AST.LinkNode(url: "data:text/html,<script>alert('xss')</script>", title: nil, children: [textNode])
        let html = try await renderer.render(node: link)
        XCTAssertEqual(html, "Data") // Should render as plain text
    }
    
    func test_renderImageNode_basicImage() async throws {
        let image = AST.ImageNode(url: "https://example.com/image.jpg", altText: "Alt text", title: nil)
        let html = try await renderer.render(node: image)
        XCTAssertEqual(html, "<img alt=\"Alt text\" src=\"https://example.com/image.jpg\" />")
    }
    
    func test_renderImageNode_withTitle() async throws {
        let image = AST.ImageNode(url: "https://example.com/image.jpg", altText: "Alt text", title: "Image title")
        let html = try await renderer.render(node: image)
        XCTAssertEqual(html, "<img alt=\"Alt text\" src=\"https://example.com/image.jpg\" title=\"Image title\" />")
    }
    
    func test_renderImageNode_unsafeURL() async throws {
        let image = AST.ImageNode(url: "javascript:alert('xss')", altText: "Alt text", title: nil)
        let html = try await renderer.render(node: image)
        XCTAssertEqual(html, "Alt text") // Should render as plain text
    }
    
    func test_renderImageNode_emptyAlt() async throws {
        let image = AST.ImageNode(url: "https://example.com/image.jpg", altText: "", title: nil)
        let html = try await renderer.render(node: image)
        XCTAssertEqual(html, "<img alt=\"\" src=\"https://example.com/image.jpg\" />")
    }
    
    // MARK: - List Tests
    
    func test_renderListNode_unorderedList() async throws {
        let item1 = AST.ListItemNode(children: [AST.ParagraphNode(children: [AST.TextNode(content: "Item 1")])])
        let item2 = AST.ListItemNode(children: [AST.ParagraphNode(children: [AST.TextNode(content: "Item 2")])])
        let list = AST.ListNode(isOrdered: false, startNumber: nil, items: [item1, item2])
        
        let html = try await renderer.render(node: list)
        let expected = "<ul>\n<li><p>Item 1</p>\n</li>\n<li><p>Item 2</p>\n</li>\n</ul>\n"
        XCTAssertEqual(html, expected)
    }
    
    func test_renderListNode_orderedList() async throws {
        let item1 = AST.ListItemNode(children: [AST.ParagraphNode(children: [AST.TextNode(content: "First")])])
        let item2 = AST.ListItemNode(children: [AST.ParagraphNode(children: [AST.TextNode(content: "Second")])])
        let list = AST.ListNode(isOrdered: true, startNumber: 1, items: [item1, item2])
        
        let html = try await renderer.render(node: list)
        let expected = "<ol>\n<li><p>First</p>\n</li>\n<li><p>Second</p>\n</li>\n</ol>\n"
        XCTAssertEqual(html, expected)
    }
    
    func test_renderListNode_orderedListWithCustomStart() async throws {
        let item1 = AST.ListItemNode(children: [AST.ParagraphNode(children: [AST.TextNode(content: "Fifth")])])
        let item2 = AST.ListItemNode(children: [AST.ParagraphNode(children: [AST.TextNode(content: "Sixth")])])
        let list = AST.ListNode(isOrdered: true, startNumber: 5, items: [item1, item2])
        
        let html = try await renderer.render(node: list)
        let expected = "<ol start=\"5\">\n<li><p>Fifth</p>\n</li>\n<li><p>Sixth</p>\n</li>\n</ol>\n"
        XCTAssertEqual(html, expected)
    }
    
    func test_renderListItemNode_multipleChildren() async throws {
        let paragraph = AST.ParagraphNode(children: [AST.TextNode(content: "Item text")])
        let codeBlock = AST.CodeBlockNode(content: "code example", language: "swift")
        let listItem = AST.ListItemNode(children: [paragraph, codeBlock])
        
        let html = try await renderer.render(node: listItem)
        let expected = "<li><p>Item text</p>\n<pre><code class=\"language-swift\">code example</code></pre>\n</li>\n"
        XCTAssertEqual(html, expected)
    }
    
    // MARK: - BlockQuote Tests
    
    func test_renderBlockQuoteNode_singleParagraph() async throws {
        let paragraph = AST.ParagraphNode(children: [AST.TextNode(content: "This is a quote.")])
        let blockQuote = AST.BlockQuoteNode(children: [paragraph])
        
        let html = try await renderer.render(node: blockQuote)
        let expected = "<blockquote>\n<p>This is a quote.</p>\n</blockquote>\n"
        XCTAssertEqual(html, expected)
    }
    
    func test_renderBlockQuoteNode_multipleParagraphs() async throws {
        let paragraph1 = AST.ParagraphNode(children: [AST.TextNode(content: "First paragraph.")])
        let paragraph2 = AST.ParagraphNode(children: [AST.TextNode(content: "Second paragraph.")])
        let blockQuote = AST.BlockQuoteNode(children: [paragraph1, paragraph2])
        
        let html = try await renderer.render(node: blockQuote)
        let expected = "<blockquote>\n<p>First paragraph.</p>\n<p>Second paragraph.</p>\n</blockquote>\n"
        XCTAssertEqual(html, expected)
    }
    
    func test_renderBlockQuoteNode_nestedBlockQuote() async throws {
        let innerParagraph = AST.ParagraphNode(children: [AST.TextNode(content: "Nested quote.")])
        let innerBlockQuote = AST.BlockQuoteNode(children: [innerParagraph])
        let outerParagraph = AST.ParagraphNode(children: [AST.TextNode(content: "Outer quote.")])
        let outerBlockQuote = AST.BlockQuoteNode(children: [outerParagraph, innerBlockQuote])
        
        let html = try await renderer.render(node: outerBlockQuote)
        let expected = "<blockquote>\n<p>Outer quote.</p>\n<blockquote>\n<p>Nested quote.</p>\n</blockquote>\n</blockquote>\n"
        XCTAssertEqual(html, expected)
    }
    
    // MARK: - Code Tests
    
    func test_renderCodeBlockNode_basicCodeBlock() async throws {
        let codeBlock = AST.CodeBlockNode(content: "let x = 42", language: nil)
        let html = try await renderer.render(node: codeBlock)
        XCTAssertEqual(html, "<pre><code>let x = 42</code></pre>\n")
    }
    
    func test_renderCodeBlockNode_withLanguage() async throws {
        let codeBlock = AST.CodeBlockNode(content: "let x = 42", language: "swift")
        let html = try await renderer.render(node: codeBlock)
        XCTAssertEqual(html, "<pre><code class=\"language-swift\">let x = 42</code></pre>\n")
    }
    
    func test_renderCodeBlockNode_escapeHTML() async throws {
        let codeBlock = AST.CodeBlockNode(content: "<script>alert('xss')</script>", language: "html")
        let html = try await renderer.render(node: codeBlock)
        XCTAssertEqual(html, "<pre><code class=\"language-html\">&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;</code></pre>\n")
    }
    
    func test_renderCodeBlockNode_multilineCode() async throws {
        let code = """
        function hello() {
            console.log("Hello, World!");
        }
        """
        let codeBlock = AST.CodeBlockNode(content: code, language: "javascript")
        let html = try await renderer.render(node: codeBlock)
        let expected = "<pre><code class=\"language-javascript\">function hello() {\n    console.log(&quot;Hello, World!&quot;);\n}</code></pre>\n"
        XCTAssertEqual(html, expected)
    }
    
    func test_renderCodeSpanNode_basicCodeSpan() async throws {
        let codeSpan = AST.CodeSpanNode(content: "let x = 42")
        let html = try await renderer.render(node: codeSpan)
        XCTAssertEqual(html, "<code>let x = 42</code>")
    }
    
    func test_renderCodeSpanNode_escapeHTML() async throws {
        let codeSpan = AST.CodeSpanNode(content: "<script>")
        let html = try await renderer.render(node: codeSpan)
        XCTAssertEqual(html, "<code>&lt;script&gt;</code>")
    }
    
    // MARK: - Line Break Tests
    
    func test_renderLineBreakNode_hardBreak() async throws {
        let lineBreak = AST.LineBreakNode(isHard: true)
        let html = try await renderer.render(node: lineBreak)
        XCTAssertEqual(html, "<br />\n")
    }
    
    func test_renderLineBreakNode_softBreak() async throws {
        let lineBreak = AST.LineBreakNode(isHard: false)
        let html = try await renderer.render(node: lineBreak)
        XCTAssertEqual(html, "\n")
    }
    
    func test_renderSoftBreakNode() async throws {
        let softBreak = AST.SoftBreakNode()
        let html = try await renderer.render(node: softBreak)
        XCTAssertEqual(html, " ")
    }
    
    // MARK: - Thematic Break Tests
    
    func test_renderThematicBreakNode() async throws {
        let thematicBreak = AST.ThematicBreakNode()
        let html = try await renderer.render(node: thematicBreak)
        XCTAssertEqual(html, "<hr />\n")
    }
    
    // MARK: - Autolink Tests
    
    func test_renderAutolinkNode_basicAutolink() async throws {
        let autolink = AST.AutolinkNode(url: "https://example.com", text: "https://example.com")
        let html = try await renderer.render(node: autolink)
        XCTAssertEqual(html, "<a href=\"https://example.com\">https://example.com</a>")
    }
    
    func test_renderAutolinkNode_emailAutolink() async throws {
        let autolink = AST.AutolinkNode(url: "mailto:test@example.com", text: "test@example.com")
        let html = try await renderer.render(node: autolink)
        XCTAssertEqual(html, "<a href=\"mailto:test@example.com\">test@example.com</a>")
    }
    
    func test_renderAutolinkNode_unsafeURL() async throws {
        let autolink = AST.AutolinkNode(url: "javascript:alert('xss')", text: "javascript:alert('xss')")
        let html = try await renderer.render(node: autolink)
        XCTAssertEqual(html, "javascript:alert(&#39;xss&#39;)") // Should render as plain text
    }
    
    // MARK: - HTML Block and Inline Tests
    
    func test_renderHTMLBlockNode_withSanitization() async throws {
        let htmlBlock = AST.HTMLBlockNode(content: "<script>alert('xss')</script>")
        let html = try await renderer.render(node: htmlBlock)
        XCTAssertEqual(html, "&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;")
    }
    
    func test_renderHTMLBlockNode_withoutSanitization() async throws {
        let context = RenderContext(sanitizeHTML: false)
        let customRenderer = HTMLRenderer(context: context)
        let htmlBlock = AST.HTMLBlockNode(content: "<div>Safe HTML</div>")
        let html = try await customRenderer.render(node: htmlBlock)
        XCTAssertEqual(html, "<div>Safe HTML</div>")
    }
    
    func test_renderHTMLInlineNode_withSanitization() async throws {
        let htmlInline = AST.HTMLInlineNode(content: "<em>emphasis</em>")
        let html = try await renderer.render(node: htmlInline)
        XCTAssertEqual(html, "&lt;em&gt;emphasis&lt;/em&gt;")
    }
    
    func test_renderHTMLInlineNode_withoutSanitization() async throws {
        let context = RenderContext(sanitizeHTML: false)
        let customRenderer = HTMLRenderer(context: context)
        let htmlInline = AST.HTMLInlineNode(content: "<strong>bold</strong>")
        let html = try await customRenderer.render(node: htmlInline)
        XCTAssertEqual(html, "<strong>bold</strong>")
    }
    
    // MARK: - GFM Extension Tests
    
    func test_renderStrikethroughNode_basicStrikethrough() async throws {
        let textNode = AST.TextNode(content: "deleted")
        let strikethrough = AST.StrikethroughNode(content: [textNode])
        let html = try await renderer.render(node: strikethrough)
        XCTAssertEqual(html, "<del>deleted</del>")
    }
    
    func test_renderStrikethroughNode_nestedElements() async throws {
        let children: [ASTNode] = [
            AST.TextNode(content: "deleted "),
            AST.ItalicNode(children: [AST.TextNode(content: "italic")])
        ]
        let strikethrough = AST.StrikethroughNode(content: children)
        let html = try await renderer.render(node: strikethrough)
        XCTAssertEqual(html, "<del>deleted <em>italic</em></del>")
    }
    
    func test_renderGFMTableNode_basicTable() async throws {
        let headerCell1 = AST.GFMTableCellNode(content: "Name", isHeader: true)
        let headerCell2 = AST.GFMTableCellNode(content: "Age", isHeader: true)
        let headerRow = AST.GFMTableRowNode(cells: [headerCell1, headerCell2], isHeader: true)
        
        let dataCell1 = AST.GFMTableCellNode(content: "John", isHeader: false)
        let dataCell2 = AST.GFMTableCellNode(content: "25", isHeader: false)
        let dataRow = AST.GFMTableRowNode(cells: [dataCell1, dataCell2], isHeader: false)
        
        let table = AST.GFMTableNode(rows: [headerRow, dataRow], alignments: [.none, .none])
        let html = try await renderer.render(node: table)
        
        let expected = """
        <table>
        <thead>
        <tr>
        <th scope="col">Name</th>
        <th scope="col">Age</th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <td>John</td>
        <td>25</td>
        </tr>
        </tbody>
        </table>
        
        """
        XCTAssertEqual(html, expected)
    }
    
    func test_renderGFMTableNode_withAlignment() async throws {
        let headerCell1 = AST.GFMTableCellNode(content: "Left", isHeader: true)
        let headerCell2 = AST.GFMTableCellNode(content: "Center", isHeader: true)
        let headerCell3 = AST.GFMTableCellNode(content: "Right", isHeader: true)
        let headerRow = AST.GFMTableRowNode(cells: [headerCell1, headerCell2, headerCell3], isHeader: true)
        
        let dataCell1 = AST.GFMTableCellNode(content: "L", isHeader: false)
        let dataCell2 = AST.GFMTableCellNode(content: "C", isHeader: false)
        let dataCell3 = AST.GFMTableCellNode(content: "R", isHeader: false)
        let dataRow = AST.GFMTableRowNode(cells: [dataCell1, dataCell2, dataCell3], isHeader: false)
        
        let table = AST.GFMTableNode(rows: [headerRow, dataRow], alignments: [.left, .center, .right])
        let html = try await renderer.render(node: table)
        
        XCTAssertTrue(html.contains("style=\"text-align: left\""))
        XCTAssertTrue(html.contains("style=\"text-align: center\""))
        XCTAssertTrue(html.contains("style=\"text-align: right\""))
    }
    
    // MARK: - Custom Styling Tests
    
    func test_renderWithCustomCSSClasses() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                cssClasses: [
                    .paragraph: "custom-paragraph",
                    .heading: "custom-heading",
                    .emphasis: "custom-italic"
                ]
            )
        )
        let customRenderer = HTMLRenderer(context: context)
        
        let textNode = AST.TextNode(content: "Hello")
        let paragraph = AST.ParagraphNode(children: [textNode])
        let html = try await customRenderer.render(node: paragraph)
        
        XCTAssertEqual(html, "<p class=\"custom-paragraph\">Hello</p>\n")
    }
    
    func test_renderWithSourcePositions() async throws {
        let sourceLocation = SourceLocation(line: 5, column: 10, offset: 100)
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                includeSourcePositions: true
            )
        )
        let customRenderer = HTMLRenderer(context: context)
        
        let textNode = AST.TextNode(content: "Hello")
        let paragraph = AST.ParagraphNode(children: [textNode], sourceLocation: sourceLocation)
        let html = try await customRenderer.render(node: paragraph)
        
        XCTAssertTrue(html.contains("data-source-line=\"5\""))
        XCTAssertTrue(html.contains("data-source-column=\"10\""))
    }
    
    func test_renderWithCustomAttributes() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                customAttributes: [
                    .paragraph: ["data-test": "value", "id": "test-paragraph"]
                ]
            )
        )
        let customRenderer = HTMLRenderer(context: context)
        
        let textNode = AST.TextNode(content: "Hello")
        let paragraph = AST.ParagraphNode(children: [textNode])
        let html = try await customRenderer.render(node: paragraph)
        
        XCTAssertTrue(html.contains("data-test=\"value\""))
        XCTAssertTrue(html.contains("id=\"test-paragraph\""))
    }
    
    func test_renderWithSyntaxHighlightingDisabled() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                syntaxHighlighting: SyntaxHighlightingConfig(enabled: false)
            )
        )
        let customRenderer = HTMLRenderer(context: context)
        
        let codeBlock = AST.CodeBlockNode(content: "let x = 42", language: "swift")
        let html = try await customRenderer.render(node: codeBlock)
        
        XCTAssertEqual(html, "<pre><code class=\"language-swift\">let x = 42</code></pre>\n")
        XCTAssertFalse(html.contains("hljs-"))  // Should not contain syntax highlighting classes
    }
    
    func test_renderWithCustomSyntaxHighlightingPrefix() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                syntaxHighlighting: SyntaxHighlightingConfig(
                    enabled: true,
                    cssPrefix: "hljs-"
                )
            )
        )
        let customRenderer = HTMLRenderer(context: context)
        
        let codeBlock = AST.CodeBlockNode(content: "let x = 42", language: "swift")
        let html = try await customRenderer.render(node: codeBlock)
        
        XCTAssertTrue(html.contains("hljs-keyword"))  // Should contain syntax highlighting with custom prefix
        XCTAssertTrue(html.contains("language-swift"))  // Should still have language class on code element
    }
    
    // MARK: - URL Normalization Tests
    
    func test_renderWithBaseURL() async throws {
        let baseURL = URL(string: "https://example.com/docs/")!
        let context = RenderContext(baseURL: baseURL)
        let customRenderer = HTMLRenderer(context: context)
        
        let textNode = AST.TextNode(content: "Link")
        let link = AST.LinkNode(url: "page.html", title: nil, children: [textNode])
        let html = try await customRenderer.render(node: link)
        
        XCTAssertEqual(html, "<a href=\"https://example.com/docs/page.html\">Link</a>")
    }
    
    func test_renderWithBaseURL_absoluteURLUnchanged() async throws {
        let baseURL = URL(string: "https://example.com/docs/")!
        let context = RenderContext(baseURL: baseURL)
        let customRenderer = HTMLRenderer(context: context)
        
        let textNode = AST.TextNode(content: "Link")
        let link = AST.LinkNode(url: "https://other.com/page.html", title: nil, children: [textNode])
        let html = try await customRenderer.render(node: link)
        
        XCTAssertEqual(html, "<a href=\"https://other.com/page.html\">Link</a>")
    }
    
    // MARK: - Document Rendering Tests
    
    func test_renderDocument_multipleElements() async throws {
        let heading = AST.HeadingNode(level: 1, children: [AST.TextNode(content: "Title")])
        let paragraph = AST.ParagraphNode(children: [AST.TextNode(content: "Content")])
        let document = AST.DocumentNode(children: [heading, paragraph])
        
        let html = try await renderer.render(document: document)
        let expected = "<h1>Title</h1>\n<p>Content</p>\n"
        XCTAssertEqual(html, expected)
    }
    
    func test_renderDocument_emptyDocument() async throws {
        let document = AST.DocumentNode(children: [])
        let html = try await renderer.render(document: document)
        XCTAssertEqual(html, "")
    }
    
    // MARK: - Error Handling Tests
    
    func test_renderUnsupportedNodeType() async throws {
        // Create a mock unsupported node type
        struct UnsupportedNode: ASTNode {
            let nodeType: ASTNodeType = .text // Using existing type for simplicity
            let children: [ASTNode] = []
            let sourceLocation: SourceLocation? = nil
        }
        
        let unsupportedNode = UnsupportedNode()
        
        do {
            _ = try await renderer.render(node: unsupportedNode)
            XCTFail("Should have thrown an error for unsupported node type")
        } catch RendererError.unsupportedNodeType {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Integration Tests
    
    func test_parseAndRenderComplexDocument() async throws {
        let markdown = """
        # Main Title
        
        This is a paragraph with **bold** and *italic* text.
        
        ## Code Example
        
        ```swift
        let greeting = "Hello, World!"
        print(greeting)
        ```
        
        ### List Example
        
        - Item 1
        - Item 2 with `inline code`
        - Item 3
        
        > This is a blockquote with a [link](https://example.com).
        
        ---
        
        | Feature | Status |
        |---------|--------|
        | Tables  | ✅     |
        | Links   | ✅     |
        """
        
        let document = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: document)
        
        // Verify key elements are present
        XCTAssertTrue(html.contains("<h1>Main Title</h1>"))
        XCTAssertTrue(html.contains("<strong>bold</strong>"))
        XCTAssertTrue(html.contains("<em>italic</em>"))
        XCTAssertTrue(html.contains("<code class=\"language-swift\">"))
        XCTAssertTrue(html.contains("<ul>"))
        XCTAssertTrue(html.contains("<code>inline code</code>"))
        XCTAssertTrue(html.contains("<blockquote>"))
        XCTAssertTrue(html.contains("<a href=\"https://example.com\">"))
        XCTAssertTrue(html.contains("<hr />"))
        XCTAssertTrue(html.contains("<table>"))
        XCTAssertTrue(html.contains("<th scope=\"col\">Feature</th>"))
        XCTAssertTrue(html.contains("<td>✅</td>"))
    }
    
    // MARK: - Performance Tests
    
    func test_renderLargeDocument() async throws {
        // Create a large document with many elements
        var children: [ASTNode] = []
        
        for i in 1...1000 {
            let heading = AST.HeadingNode(level: 2, children: [AST.TextNode(content: "Section \(i)")])
            let paragraph = AST.ParagraphNode(children: [AST.TextNode(content: "Content for section \(i)")])
            children.append(heading)
            children.append(paragraph)
        }
        
        let document = AST.DocumentNode(children: children)
        
        let startTime = Date()
        let html = try await renderer.render(document: document)
        let endTime = Date()
        
        let renderTime = endTime.timeIntervalSince(startTime)
        print("Rendered 1000 sections in \(renderTime) seconds")
        
        // Verify the output contains expected elements
        XCTAssertTrue(html.contains("<h2>Section 1</h2>"))
        XCTAssertTrue(html.contains("<h2>Section 1000</h2>"))
        XCTAssertTrue(renderTime < 1.0) // Should render quickly
    }
} 
