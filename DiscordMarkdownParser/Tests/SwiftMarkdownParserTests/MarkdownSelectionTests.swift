import XCTest
@testable import DiscordMarkdownParser

/// Test suite for specific markdown selection content
/// Tests parsing of numbered lists with bold text and code blocks
final class MarkdownSelectionTests: XCTestCase {
    
    var parser: DiscordMarkdownParser!
    
    override func setUp() {
        super.setUp()
        // Enable GFM extensions and source location tracking for comprehensive testing
        let config = DiscordMarkdownParser.Configuration(
            enableGFMExtensions: true,
            strictMode: false,
            trackSourceLocations: true
        )
        parser = DiscordMarkdownParser(configuration: config)
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    /// Test the parsing of the GitHub instructions markdown selection
    /// This tests a complex structure with numbered lists, bold text, and code blocks
    func test_parseGitHubInstructionsMarkdown() async throws {
        let markdown = """
        1. **Fork the repository** on GitHub
        2. **Clone your fork**:
           ```bash
           git clone https://github.com/YOUR_USERNAME/DiscordMarkdownParser.git
           cd DiscordMarkdownParser
           ```
        3. **Create a feature branch**:
           ```bash
           git checkout -b feature/your-feature-name
           ```
        """
        
        let document = try await parser.parseToAST(markdown)
        
        // Basic validation
        XCTAssertNotNil(document, "Document should be parsed successfully")
        XCTAssertEqual(document.children.count, 1, "Document should have one child (the ordered list)")
        
        // Should have one ordered list
        guard let list = document.children.first as? AST.ListNode else {
            XCTFail("Expected ListNode, got \(type(of: document.children.first))")
            return
        }
        
        XCTAssertTrue(list.isOrdered, "List should be ordered (numbered)")
        XCTAssertEqual(list.items.count, 3, "List should have 3 items")
        
        // Test first item: should contain "Fork the repository"
        let firstItem = list.items[0] as! AST.ListItemNode
        XCTAssertEqual(firstItem.children.count, 1, "First item should have one child (paragraph)")
        
        let firstParagraph = firstItem.children[0] as! AST.ParagraphNode
        
        // Check for bold text in first item
        let hasBoldText = firstParagraph.children.contains { node in
            if let strongNode = node as? AST.BoldNode {
                // Collect all text content from the strong emphasis node
                let textContent = strongNode.children.compactMap { child in
                    if let textNode = child as? AST.TextNode {
                        return textNode.content
                    }
                    return nil
                }.joined()
                return textContent.contains("Fork") && textContent.contains("the") && textContent.contains("repository")
            }
            return false
        }
        XCTAssertTrue(hasBoldText, "First item should contain bold 'Fork the repository' text")
        
        // Test second item: should contain "Clone your fork" text and code block
        let secondItem = list.items[1] as! AST.ListItemNode
        XCTAssertEqual(secondItem.children.count, 2, "Second item should have 2 children (paragraph + code block)")
        
        let secondParagraph = secondItem.children[0] as! AST.ParagraphNode
        
        // Check for code block in second item
        let hasSecondCodeBlock = secondItem.children.contains { node in
            if let codeBlock = node as? AST.CodeBlockNode {
                return codeBlock.language == "bash" && 
                       codeBlock.content.contains("git clone") && 
                       codeBlock.content.contains("cd DiscordMarkdownParser")
            }
            return false
        }
        XCTAssertTrue(hasSecondCodeBlock, "Second item should contain a bash code block with git clone commands")
        
        // Check for bold text in second item
        let hasCloneBoldText = secondParagraph.children.contains { node in
            if let strongNode = node as? AST.BoldNode {
                // Collect all text content from the strong emphasis node
                let textContent = strongNode.children.compactMap { child in
                    if let textNode = child as? AST.TextNode {
                        return textNode.content
                    }
                    return nil
                }.joined()
                return textContent.contains("Clone") && textContent.contains("your") && textContent.contains("fork")
            }
            return false
        }
        XCTAssertTrue(hasCloneBoldText, "Second item should contain bold 'Clone your fork' text")
        
        // Test third item: should contain "Create a feature branch" text and code block
        let thirdItem = list.items[2] as! AST.ListItemNode
        XCTAssertEqual(thirdItem.children.count, 2, "Third item should have 2 children (paragraph + code block)")
        
        let thirdParagraph = thirdItem.children[0] as! AST.ParagraphNode
        
        // Check for code block in third item
        let hasThirdCodeBlock = thirdItem.children.contains { node in
            if let codeBlock = node as? AST.CodeBlockNode {
                return codeBlock.language == "bash" && 
                       codeBlock.content.contains("git checkout -b")
            }
            return false
        }
        XCTAssertTrue(hasThirdCodeBlock, "Third item should contain a bash code block with git checkout command")
        
        // Check for bold text in third item
        let hasFeatureBoldText = thirdParagraph.children.contains { node in
            if let strongNode = node as? AST.BoldNode {
                // Collect all text content from the strong emphasis node
                let textContent = strongNode.children.compactMap { child in
                    if let textNode = child as? AST.TextNode {
                        return textNode.content
                    }
                    return nil
                }.joined()
                return textContent.contains("Create") && textContent.contains("feature") && textContent.contains("branch")
            }
            return false
        }
        XCTAssertTrue(hasFeatureBoldText, "Third item should contain bold 'Create a feature branch' text")
    }
    
    /// Test HTML rendering of the GitHub instructions markdown
    /// 
    /// This test validates that the parser correctly handles complex list structures with multiple code blocks.
    /// Expected behavior: 3 list items with 2 separate code blocks should produce 2 <pre> tags.
    func test_renderGitHubInstructionsToHTML() async throws {
        let markdown = """
        1. **Fork the repository** on GitHub
        2. **Clone your fork**:
           ```bash
           git clone https://github.com/YOUR_USERNAME/DiscordMarkdownParser.git
           cd DiscordMarkdownParser
           ```
        3. **Create a feature branch**:
           ```bash
           git checkout -b feature/your-feature-name
           ```
        """
        
        let html = try await parser.parseToHTML(markdown)
        
        // Basic HTML structure validation
        XCTAssertTrue(html.contains("<ol>"), "HTML should contain ordered list tag")
        XCTAssertTrue(html.contains("</ol>"), "HTML should contain closing ordered list tag")
        XCTAssertTrue(html.contains("<li>"), "HTML should contain list item tags")
        XCTAssertTrue(html.contains("</li>"), "HTML should contain closing list item tags")
        
        // Check for bold text rendering
        XCTAssertTrue(html.contains("<strong>Fork the repository</strong>"), "HTML should contain bold 'Fork the repository'")
        XCTAssertTrue(html.contains("<strong>Clone your fork</strong>"), "HTML should contain bold 'Clone your fork'")
        XCTAssertTrue(html.contains("<strong>Create a feature branch</strong>"), "HTML should contain bold 'Create a feature branch'")
        
        // Check for code block rendering - there should be 2 separate code blocks
        let preTagCount = html.components(separatedBy: "<pre>").count - 1
        XCTAssertEqual(preTagCount, 2, "HTML should contain exactly 2 <pre> tags for the 2 code blocks")
        
        XCTAssertTrue(html.contains("language-bash"), "HTML should specify bash language for code blocks")
        XCTAssertTrue(html.contains("git clone"), "HTML should contain git clone command")
        XCTAssertTrue(html.contains("git checkout -b"), "HTML should contain git checkout command")
        
        // Verify it's a well-formed HTML structure
        XCTAssertFalse(html.isEmpty, "HTML output should not be empty")
    }
    
    // MARK: - Individual Element Tests
    
    /// Test parsing of simple ordered lists
    func test_parseOrderedList() async throws {
        let markdown = """
        1. First item
        2. Second item
        3. Third item
        """
        
        let document = try await parser.parseToAST(markdown)
        
        guard let list = document.children.first as? AST.ListNode else {
            XCTFail("Expected ListNode")
            return
        }
        
        XCTAssertTrue(list.isOrdered, "List should be ordered")
        XCTAssertEqual(list.startNumber, 1, "List should start at 1")
        XCTAssertEqual(list.items.count, 3, "List should have 3 items")
    }
    
    /// Test parsing of bold text within list items
    func test_parseBoldTextInList() async throws {
        let markdown = "1. **Bold text** in list item"
        
        let document = try await parser.parseToAST(markdown)
        
        guard let list = document.children.first as? AST.ListNode,
              let firstItem = list.items.first as? AST.ListItemNode,
              let paragraph = firstItem.children.first as? AST.ParagraphNode else {
            XCTFail("Expected list structure")
            return
        }
        
        let hasBoldText = paragraph.children.contains { $0 is AST.BoldNode }
        XCTAssertTrue(hasBoldText, "List item should contain bold text")
    }
    
    /// Test parsing of code blocks within list items
    func test_parseCodeBlockInList() async throws {
        let markdown = """
        1. List item with code:
           ```
           code content
           ```
        """
        
        let document = try await parser.parseToAST(markdown)
        
        guard let list = document.children.first as? AST.ListNode,
              let firstItem = list.items.first as? AST.ListItemNode else {
            XCTFail("Expected list structure")
            return
        }
        
        let hasCodeBlock = firstItem.children.contains { $0 is AST.CodeBlockNode }
        XCTAssertTrue(hasCodeBlock, "List item should contain code block")
    }
} 
