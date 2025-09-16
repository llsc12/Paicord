import XCTest
import SwiftUI
@testable import DiscordMarkdownParser

/// Integration tests for SwiftUIRenderer with real markdown content
@available(iOS 17.0, macOS 14.0, *)
final class SwiftUIRendererIntegrationTests: XCTestCase {
    
    var renderer: SwiftUIRenderer!
    var parser: DiscordMarkdownParser!
    
    override func setUp() {
        super.setUp()
        renderer = SwiftUIRenderer()
        parser = DiscordMarkdownParser()
    }
    
    override func tearDown() {
        renderer = nil
        parser = nil
        super.tearDown()
    }
    
    // MARK: - Basic Text Rendering Tests
    
    func test_renderSimpleText() async throws {
        let markdown = "Hello World"
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    func test_renderParagraph() async throws {
        let markdown = "This is a simple paragraph with some text."
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    func test_renderMultipleParagraphs() async throws {
        let markdown = """
        First paragraph with some text.
        
        Second paragraph with more text.
        
        Third paragraph to test spacing.
        """
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    // MARK: - Heading Rendering Tests
    
    func test_renderHeadings() async throws {
        let markdown = """
        # Heading 1
        ## Heading 2
        ### Heading 3
        #### Heading 4
        ##### Heading 5
        ###### Heading 6
        """
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    // MARK: - Inline Elements Tests
    
    func test_renderEmphasis() async throws {
        let markdown = "This text has *italic* and **bold** formatting."
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    func test_renderLinks() async throws {
        let markdown = "Check out [Swift](https://swift.org) and [SwiftUI](https://developer.apple.com/xcode/swiftui/)."
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    func test_renderImages() async throws {
        let markdown = "Here's an image: ![Alt text](https://example.com/image.png)"
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    func test_renderCodeSpans() async throws {
        let markdown = "Use `print(\"Hello\")` to output text in Swift."
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    // MARK: - Block Elements Tests
    
    func test_renderCodeBlocks() async throws {
        let markdown = """
        Here's a Swift code example:
        
        ```swift
        func greet(name: String) {
            print("Hello, \\(name)!")
        }
        ```
        """
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    func test_renderLists() async throws {
        let markdown = """
        Unordered list:
        - Item 1
        - Item 2
        - Item 3
        
        Ordered list:
        1. First item
        2. Second item
        3. Third item
        """
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    func test_renderBlockQuotes() async throws {
        let markdown = """
        > This is a blockquote.
        > It can span multiple lines.
        >
        > And have multiple paragraphs.
        """
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    func test_renderThematicBreaks() async throws {
        let markdown = """
        Section 1
        
        ---
        
        Section 2
        """
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    // MARK: - GFM Extensions Tests
    
    func test_renderTaskLists() async throws {
        let markdown = """
        Task list:
        - [x] Completed task
        - [ ] Incomplete task
        - [x] Another completed task
        """
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    func test_renderStrikethrough() async throws {
        let markdown = "This text has ~~strikethrough~~ formatting."
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    func test_renderTables() async throws {
        let markdown = """
        | Name | Age | City |
        |------|-----|------|
        | John | 25  | NYC  |
        | Jane | 30  | LA   |
        """
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    // MARK: - Complex Integration Tests
    
    func test_renderComplexDocument() async throws {
        let markdown = """
        # SwiftUI Markdown Renderer
        
        This is a **comprehensive test** of the SwiftUI markdown renderer.
        
        ## Features
        
        The renderer supports:
        
        - *Italic* and **bold** text
        - [Links](https://swift.org)
        - `inline code`
        - Images: ![Swift Logo](https://swift.org/assets/images/swift.svg)
        
        ### Code Example
        
        ```swift
        import SwiftUI
        
        struct ContentView: View {
            var body: some View {
                Text("Hello, SwiftUI!")
            }
        }
        ```
        
        ### Task List
        
        - [x] Implement basic text rendering
        - [x] Add support for headings
        - [ ] Add syntax highlighting
        - [ ] Optimize performance
        
        ### Quote
        
        > "SwiftUI is a modern way to declare user interfaces for any Apple platform."
        > - Apple Developer Documentation
        
        ---
        
        ## Table Example
        
        | Feature | Status | Priority |
        |---------|--------|----------|
        | Text    | ✅     | High     |
        | Links   | ✅     | High     |
        | Images  | ✅     | Medium   |
        | Tables  | ✅     | Low      |
        
        That's all for now!
        """
        
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    // MARK: - Performance Tests
    
    func test_renderingPerformance() async throws {
        let markdown = String(repeating: "This is a paragraph with some text. ", count: 100)
        let document = try await parser.parseToAST(markdown)
        
        let startTime = Date()
        let view = try await renderer.render(document: document)
        let endTime = Date()
        
        XCTAssertNotNil(view)
        let renderTime = endTime.timeIntervalSince(startTime)
        XCTAssertLessThan(renderTime, 0.5, "Rendering should be fast even for large documents")
    }
    
    // MARK: - Edge Cases Tests
    
    func test_renderEmptyDocument() async throws {
        let markdown = ""
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    func test_renderWhitespaceOnlyDocument() async throws {
        let markdown = "   \n\n   \n   "
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    func test_renderUnicodeContent() async throws {
        let markdown = """
        # Unicode Test 🌍
        
        This document contains various Unicode characters:
        - Emoji: 😀 🎉 ✨ 🚀
        - Chinese: 你好世界
        - Arabic: مرحبا بالعالم
        - Russian: Привет мир
        - Mathematical: ∑ ∞ π ∫
        """
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
    
    func test_renderMalformedMarkdown() async throws {
        let markdown = """
        # Unclosed emphasis *italic text
        
        [Broken link](
        
        ```
        Unclosed code block
        """
        let document = try await parser.parseToAST(markdown)
        let view = try await renderer.render(document: document)
        XCTAssertNotNil(view)
    }
} 
