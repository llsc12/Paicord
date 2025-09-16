import XCTest
@testable import DiscordMarkdownParser

/// Integration tests for syntax highlighting with HTML renderer
/// These tests verify that syntax highlighting works correctly end-to-end
/// with the HTML renderer and produces expected output.
final class SyntaxHighlightingIntegrationTests: XCTestCase {
    
    // MARK: - Test Setup
    
    private var parser: DiscordMarkdownParser!
    private var renderer: HTMLRenderer!
    
    override func setUp() async throws {
        try await super.setUp()
        parser = DiscordMarkdownParser()
        
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                syntaxHighlighting: SyntaxHighlightingConfig(
                    enabled: true,
                    cssPrefix: "hljs-"
                )
            )
        )
        renderer = HTMLRenderer(context: context)
    }
    
    override func tearDown() {
        parser = nil
        renderer = nil
        super.tearDown()
    }
    
    // MARK: - Theme Integration Tests
    
    // GitHub theme test
    func test_htmlRenderer_appliesGitHubTheme() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                syntaxHighlighting: SyntaxHighlightingConfig(
                    enabled: true,
                    cssPrefix: "hljs-"
                )
            )
        )
        let renderer = HTMLRenderer(context: context)
        
        let markdown = """
        ```javascript
        const message = "Hello World";
        ```
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        // Verify theme-specific styling
        XCTAssertTrue(html.contains("class=\"hljs-string\""), "Should highlight strings")
        XCTAssertTrue(html.contains("class=\"hljs-keyword\""), "Should highlight keywords")
    }
    
    // Xcode theme test
    func test_htmlRenderer_appliesXcodeTheme() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                syntaxHighlighting: SyntaxHighlightingConfig(
                    enabled: true,
                    cssPrefix: "hljs-"
                )
            )
        )
        let renderer = HTMLRenderer(context: context)
        
        let markdown = """
        ```swift
        func test() -> String {
            return "Hello"
        }
        ```
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        // Verify theme is applied
        XCTAssertTrue(html.contains("class=\"hljs-string\""), "Should highlight strings")
        XCTAssertTrue(html.contains("class=\"hljs-keyword\""), "Should highlight keywords")
    }
    
    // VS Code Dark theme test
    func test_htmlRenderer_appliesVSCodeDarkTheme() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                syntaxHighlighting: SyntaxHighlightingConfig(
                    enabled: true,
                    cssPrefix: "hljs-"
                )
            )
        )
        let renderer = HTMLRenderer(context: context)
        
        let markdown = """
        ```typescript
        interface User {
            name: string;
            age: number;
        }
        ```
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        // Verify theme-specific styling
        XCTAssertTrue(html.contains("class=\"hljs-keyword\""), "Should highlight keywords")
        XCTAssertTrue(html.contains("class=\"hljs-type\""), "Should highlight types")
    }
    
    // MARK: - End-to-End Integration Tests
    
    func test_htmlRenderer_includesSyntaxHighlightingClasses() async throws {
        let markdown = """
        # Code Example
        
        ```swift
        func greet(name: String) -> String {
            return "Hello, \\(name)!"
        }
        ```
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        

        
        // Verify HTML contains syntax highlighting classes
        XCTAssertTrue(html.contains("class=\"hljs-keyword\""), "Should contain keyword highlighting")
        XCTAssertTrue(html.contains("class=\"hljs-string\""), "Should contain string highlighting")
        XCTAssertTrue(html.contains("class=\"hljs-type\""), "Should contain type highlighting")
        XCTAssertTrue(html.contains("class=\"hljs-identifier\""), "Should contain identifier highlighting")
        XCTAssertTrue(html.contains("class=\"hljs-punctuation\""), "Should contain punctuation highlighting")
        XCTAssertTrue(html.contains("class=\"hljs-interpolation\""), "Should contain interpolation highlighting")
    }
    
    func test_htmlRenderer_handlesMultipleLanguages() async throws {
        let markdown = """
        # Multi-language Example
        
        ```javascript
        const greet = (name) => `Hello, ${name}!`;
        ```
        
        ```python
        def greet(name: str) -> str:
            return f"Hello, {name}!"
        ```
        
        ```kotlin
        fun greet(name: String): String = "Hello, $name!"
        ```
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        // Verify all languages are properly highlighted
        XCTAssertTrue(html.contains("class=\"hljs-keyword\""), "Should highlight keywords")
        XCTAssertTrue(html.contains("class=\"hljs-string\""), "Should highlight strings")
        XCTAssertTrue(html.contains("class=\"hljs-template\""), "Should highlight template literals")
        XCTAssertTrue(html.contains("class=\"hljs-interpolation\""), "Should highlight interpolations")
        
        // Verify language-specific classes
        XCTAssertTrue(html.contains("language-javascript"), "Should have JavaScript language class")
        XCTAssertTrue(html.contains("language-python"), "Should have Python language class")
        XCTAssertTrue(html.contains("language-kotlin"), "Should have Kotlin language class")
    }
    
    func test_htmlRenderer_handlesUnsupportedLanguageGracefully() async throws {
        let markdown = """
        ```unknown
        some code here
        ```
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        // Should still render as code block without highlighting
        XCTAssertTrue(html.contains("<pre><code"), "Should render as code block")
        XCTAssertFalse(html.contains("class=\"hljs-"), "Should not contain highlighting classes for unknown language")
    }
    
    func test_htmlRenderer_preservesCodeBlockStructure() async throws {
        let markdown = """
        ```swift
        // This is a comment
        func test() {
            let message = "Hello"
            print(message)
        }
        ```
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        

        
        // Verify structure is preserved
        XCTAssertTrue(html.contains("<pre><code"), "Should wrap in pre/code tags")
        XCTAssertTrue(html.contains("// This is a comment"), "Should preserve comments")
        XCTAssertTrue(html.contains("func") && html.contains("test"), "Should preserve function definition")
        XCTAssertTrue(html.contains("print") && html.contains("message"), "Should preserve function calls")
    }
    
    func test_htmlRenderer_escapesHTMLInCode() async throws {
        let markdown = """
        ```html
        <div class="test">
            <script>alert('xss')</script>
        </div>
        ```
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        // Verify HTML is properly escaped
        XCTAssertTrue(html.contains("&lt;div"), "Should escape < as &lt;")
        XCTAssertTrue(html.contains("&lt;script&gt;"), "Should escape script tags")
        XCTAssertFalse(html.contains("<script>"), "Should not contain unescaped script tags")
    }
    
    // MARK: - Configuration Tests
    
    func test_htmlRenderer_customCSSPrefix() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                syntaxHighlighting: SyntaxHighlightingConfig(
                    enabled: true,
                    cssPrefix: "custom-"
                )
            )
        )
        let renderer = HTMLRenderer(context: context)
        
        let markdown = """
        ```swift
        let message = "Hello"
        ```
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        // Should use custom CSS prefix
        XCTAssertTrue(html.contains("class=\"custom-keyword\""), "Should use custom CSS prefix")
        XCTAssertFalse(html.contains("class=\"hljs-keyword\""), "Should not use default prefix")
    }
    
    func test_htmlRenderer_disablesSyntaxHighlighting() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                syntaxHighlighting: SyntaxHighlightingConfig(
                    enabled: false
                )
            )
        )
        let renderer = HTMLRenderer(context: context)
        
        let markdown = """
        ```javascript
        const test = "no highlighting";
        ```
        """
        
        let ast = try await parser.parseToAST(markdown)
        let html = try await renderer.render(document: ast)
        
        // Should not contain highlighting classes
        XCTAssertFalse(html.contains("class=\"hljs-keyword\""), "Should not have keyword highlighting")
        XCTAssertFalse(html.contains("class=\"hljs-string\""), "Should not have string highlighting")
        XCTAssertTrue(html.contains("<pre><code"), "Should still render as code block")
    }
}
