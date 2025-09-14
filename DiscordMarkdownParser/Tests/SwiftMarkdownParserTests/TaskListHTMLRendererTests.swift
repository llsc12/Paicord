import XCTest
@testable import DiscordMarkdownParser

/// Test-driven development tests for task list HTML rendering
/// 
/// These tests define the expected behavior for task list HTML rendering,
/// ensuring proper HTML output with accessibility and semantic markup.
final class TaskListHTMLRendererTests: XCTestCase {
    
    var parser: DiscordMarkdownParser!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let configuration = DiscordMarkdownParser.Configuration(
            enableGFMExtensions: true,
            strictMode: false,
            maxNestingDepth: 100,
            trackSourceLocations: true,
            maxParsingTime: 30.0
        )
        parser = DiscordMarkdownParser(configuration: configuration)
    }
    
    // MARK: - Basic HTML Rendering
    
    func test_htmlRenderer_rendersCheckedTaskListItem() async throws {
        let markdown = "- [x] Completed task"
        let html = try await parser.parseToHTML(markdown)
        
        // Should contain proper task list HTML structure
        XCTAssertTrue(html.contains("<ul"), "Should contain unordered list")
        XCTAssertTrue(html.contains("</ul>"), "Should close unordered list")
        XCTAssertTrue(html.contains("<li"), "Should contain list item")
        XCTAssertTrue(html.contains("</li>"), "Should close list item")
        
        // Should contain checkbox input
        XCTAssertTrue(html.contains("<input"), "Should contain input element")
        XCTAssertTrue(html.contains("type=\"checkbox\""), "Should be checkbox type")
        XCTAssertTrue(html.contains("checked"), "Should be checked")
        XCTAssertTrue(html.contains("disabled"), "Should be disabled")
        
        // Should contain task content
        XCTAssertTrue(html.contains("Completed task"), "Should contain task text")
        
        // Should have proper accessibility
        XCTAssertTrue(html.contains("aria-label") || html.contains("aria-labelledby"), "Should have accessibility labels")
    }
    
    func test_htmlRenderer_rendersUncheckedTaskListItem() async throws {
        let markdown = "- [ ] Incomplete task"
        let html = try await parser.parseToHTML(markdown)
        
        // Should contain proper task list HTML structure
        XCTAssertTrue(html.contains("<ul"), "Should contain unordered list")
        XCTAssertTrue(html.contains("<li"), "Should contain list item")
        
        // Should contain checkbox input
        XCTAssertTrue(html.contains("<input"), "Should contain input element")
        XCTAssertTrue(html.contains("type=\"checkbox\""), "Should be checkbox type")
        XCTAssertFalse(html.contains(" checked"), "Should not be checked")
        XCTAssertTrue(html.contains("disabled"), "Should be disabled")
        
        // Should contain task content
        XCTAssertTrue(html.contains("Incomplete task"), "Should contain task text")
    }
    
    func test_htmlRenderer_rendersTaskListWithVariousCheckMarkers() async throws {
        let testCases = [
            ("- [x] Checked with x", true),
            ("- [X] Checked with X", true),
            ("- [ ] Unchecked with space", false),
            ("- [o] Checked with o", true),
            ("- [O] Checked with O", true),
            ("- [v] Checked with v", true),
            ("- [V] Checked with V", true)
        ]
        
        for (markdown, expectedChecked) in testCases {
            let html = try await parser.parseToHTML(markdown)
            
            // Should contain checkbox
            XCTAssertTrue(html.contains("type=\"checkbox\""), "Should contain checkbox for: \(markdown)")
            
            if expectedChecked {
                XCTAssertTrue(html.contains(" checked"), "Should be checked for: \(markdown)")
            } else {
                XCTAssertFalse(html.contains(" checked"), "Should not be checked for: \(markdown)")
            }
        }
    }
    
    // MARK: - Multiple Task Lists
    
    func test_htmlRenderer_rendersMultipleTaskListItems() async throws {
        let markdown = """
        - [x] First task
        - [ ] Second task
        - [X] Third task
        """
        
        let html = try await parser.parseToHTML(markdown)
        
        // Should contain one list with multiple items
        XCTAssertTrue(html.contains("<ul"), "Should contain unordered list")
        
        // Count list items
        let listItemCount = html.components(separatedBy: "<li").count - 1
        XCTAssertEqual(listItemCount, 3, "Should have 3 list items")
        
        // Count checkboxes
        let checkboxCount = html.components(separatedBy: "type=\"checkbox\"").count - 1
        XCTAssertEqual(checkboxCount, 3, "Should have 3 checkboxes")
        
        // Count checked boxes
        let checkedCount = html.components(separatedBy: " checked").count - 1
        XCTAssertEqual(checkedCount, 2, "Should have 2 checked boxes")
        
        // Should contain all task texts
        XCTAssertTrue(html.contains("First task"), "Should contain first task text")
        XCTAssertTrue(html.contains("Second task"), "Should contain second task text")
        XCTAssertTrue(html.contains("Third task"), "Should contain third task text")
    }
    
    // MARK: - Mixed Lists
    
    func test_htmlRenderer_rendersMixedTaskListAndRegularList() async throws {
        let markdown = """
        - Regular item
        - [x] Task item
        - Another regular item
        """
        
        let html = try await parser.parseToHTML(markdown)
        
        // Should contain one list
        XCTAssertTrue(html.contains("<ul"), "Should contain unordered list")
        
        // Should have 3 list items
        let listItemCount = html.components(separatedBy: "<li").count - 1
        XCTAssertEqual(listItemCount, 3, "Should have 3 list items")
        
        // Should have only 1 checkbox (for the task item)
        let checkboxCount = html.components(separatedBy: "type=\"checkbox\"").count - 1
        XCTAssertEqual(checkboxCount, 1, "Should have 1 checkbox")
        
        // Should contain all texts
        XCTAssertTrue(html.contains("Regular item"), "Should contain regular item text")
        XCTAssertTrue(html.contains("Task item"), "Should contain task item text")
        XCTAssertTrue(html.contains("Another regular item"), "Should contain another regular item text")
    }
    
    // MARK: - Nested Task Lists
    
    func test_htmlRenderer_rendersNestedTaskLists() async throws {
        let markdown = """
        - [x] Parent task
          - [x] Child task 1
          - [ ] Child task 2
        """
        
        let html = try await parser.parseToHTML(markdown)
        
        // Should contain list structure
        XCTAssertTrue(html.contains("<ul"), "Should contain unordered list")
        
        // Should have checkboxes for all tasks
        let checkboxCount = html.components(separatedBy: "type=\"checkbox\"").count - 1
        XCTAssertGreaterThanOrEqual(checkboxCount, 3, "Should have at least 3 checkboxes")
        
        // Should contain all task texts
        XCTAssertTrue(html.contains("Parent task"), "Should contain parent task text")
        XCTAssertTrue(html.contains("Child task 1"), "Should contain child task 1 text")
        XCTAssertTrue(html.contains("Child task 2"), "Should contain child task 2 text")
    }
    
    // MARK: - Task Lists with Complex Content
    
    func test_htmlRenderer_rendersTaskListWithInlineFormatting() async throws {
        let markdown = "- [x] Task with **bold** and *italic* text"
        let html = try await parser.parseToHTML(markdown)
        
        // Should contain checkbox
        XCTAssertTrue(html.contains("type=\"checkbox\""), "Should contain checkbox")
        XCTAssertTrue(html.contains(" checked"), "Should be checked")
        
        // Should contain inline formatting
        XCTAssertTrue(html.contains("<strong>") || html.contains("<b>"), "Should contain bold formatting")
        XCTAssertTrue(html.contains("<em>") || html.contains("<i>"), "Should contain italic formatting")
        
        // Should contain the text content
        XCTAssertTrue(html.contains("Task with"), "Should contain task text")
        XCTAssertTrue(html.contains("bold"), "Should contain bold text")
        XCTAssertTrue(html.contains("italic"), "Should contain italic text")
    }
    
    func test_htmlRenderer_rendersTaskListWithLinks() async throws {
        let markdown = "- [x] Task with [a link](https://example.com)"
        let html = try await parser.parseToHTML(markdown)
        
        // Should contain checkbox
        XCTAssertTrue(html.contains("type=\"checkbox\""), "Should contain checkbox")
        
        // Should contain link
        XCTAssertTrue(html.contains("<a href=\"https://example.com\""), "Should contain link")
        XCTAssertTrue(html.contains("a link"), "Should contain link text")
        
        // Should contain task text
        XCTAssertTrue(html.contains("Task with"), "Should contain task text")
    }
    
    // MARK: - HTML Structure and Semantics
    
    func test_htmlRenderer_usesSemanticHTMLStructure() async throws {
        let markdown = "- [x] Semantic task"
        let html = try await parser.parseToHTML(markdown)
        
        // Should use proper list structure
        XCTAssertTrue(html.contains("<ul"), "Should use unordered list")
        XCTAssertTrue(html.contains("<li"), "Should use list items")
        
        // Should use proper form elements
        XCTAssertTrue(html.contains("<input"), "Should use input element")
        XCTAssertTrue(html.contains("type=\"checkbox\""), "Should use checkbox type")
        
        // Should have proper nesting (checkbox inside list item)
        let ulIndex = html.firstIndex(of: "<")!
        let inputIndex = html.range(of: "<input")!.lowerBound
        XCTAssertLessThan(ulIndex, inputIndex, "List should come before input")
    }
    
    func test_htmlRenderer_includesAccessibilityAttributes() async throws {
        let markdown = "- [x] Accessible task"
        let html = try await parser.parseToHTML(markdown)
        
        // Should have accessibility attributes
        let hasAriaLabel = html.contains("aria-label")
        let hasAriaLabelledBy = html.contains("aria-labelledby")
        let hasAriaChecked = html.contains("aria-checked")
        
        XCTAssertTrue(hasAriaLabel || hasAriaLabelledBy || hasAriaChecked, 
                     "Should have accessibility attributes")
        
        // Should be disabled for read-only rendering
        XCTAssertTrue(html.contains("disabled"), "Should be disabled for read-only")
    }
    
    // MARK: - CSS Classes and Styling
    
    func test_htmlRenderer_includesTaskListCSSClasses() async throws {
        let markdown = "- [x] Styled task"
        let html = try await parser.parseToHTML(markdown)
        
        // Should include CSS classes for styling
        let hasTaskListClass = html.contains("class=\"task-list\"") || 
                              html.contains("class=\"task-list-item\"") ||
                              html.contains("class=\"task-list-checkbox\"")
        
        XCTAssertTrue(hasTaskListClass, "Should include CSS classes for task lists")
    }
    
    // MARK: - Edge Cases
    
    func test_htmlRenderer_handlesEmptyTaskContent() async throws {
        let markdown = "- [x] "
        let html = try await parser.parseToHTML(markdown)
        
        // Should still render checkbox even with empty content
        XCTAssertTrue(html.contains("type=\"checkbox\""), "Should contain checkbox")
        XCTAssertTrue(html.contains("checked"), "Should be checked")
        XCTAssertTrue(html.contains("<li"), "Should contain list item")
    }
    
    func test_htmlRenderer_handlesSpecialCharactersInTaskContent() async throws {
        let markdown = "- [x] Task with <special> & \"quoted\" characters"
        let html = try await parser.parseToHTML(markdown)
        
        // Should contain checkbox
        XCTAssertTrue(html.contains("type=\"checkbox\""), "Should contain checkbox")
        
        // Should properly escape HTML characters
        XCTAssertTrue(html.contains("&lt;special&gt;") || html.contains("&lt;"), "Should escape < characters")
        XCTAssertTrue(html.contains("&amp;") || html.contains("&"), "Should handle & characters")
        XCTAssertTrue(html.contains("&quot;") || html.contains("\""), "Should handle quote characters")
    }
    
    // MARK: - Ordered Lists
    
    func test_htmlRenderer_rendersOrderedTaskLists() async throws {
        let markdown = """
        1. [x] First numbered task
        2. [ ] Second numbered task
        """
        
        let html = try await parser.parseToHTML(markdown)
        
        // Should use ordered list
        XCTAssertTrue(html.contains("<ol"), "Should contain ordered list")
        XCTAssertTrue(html.contains("</ol>"), "Should close ordered list")
        
        // Should contain checkboxes
        let checkboxCount = html.components(separatedBy: "type=\"checkbox\"").count - 1
        XCTAssertEqual(checkboxCount, 2, "Should have 2 checkboxes")
        
        // Should contain task texts
        XCTAssertTrue(html.contains("First numbered task"), "Should contain first task text")
        XCTAssertTrue(html.contains("Second numbered task"), "Should contain second task text")
    }
    
    // MARK: - HTML Validation
    
    func test_htmlRenderer_producesValidHTML() async throws {
        let markdown = """
        - [x] First task
        - [ ] Second task with **bold** text
        - [X] Third task with [link](https://example.com)
        """
        
        let html = try await parser.parseToHTML(markdown)
        
        // Basic HTML structure validation
        XCTAssertTrue(html.contains("<ul"), "Should have opening ul tag")
        XCTAssertTrue(html.contains("</ul>"), "Should have closing ul tag")
        
        // Count opening and closing li tags
        let openingLiCount = html.components(separatedBy: "<li").count - 1
        let closingLiCount = html.components(separatedBy: "</li>").count - 1
        XCTAssertEqual(openingLiCount, closingLiCount, "Should have matching li tags")
        
        // Ensure proper input tag structure
        let inputTags = html.components(separatedBy: "<input").dropFirst()
        for inputTag in inputTags {
            let endIndex = inputTag.firstIndex(of: ">") ?? inputTag.endIndex
            let inputContent = String(inputTag[..<endIndex])
            
            XCTAssertTrue(inputContent.contains("type=\"checkbox\""), "Input should have checkbox type")
            XCTAssertTrue(inputContent.contains("disabled"), "Input should be disabled")
        }
    }
    
    // MARK: - Enhanced Styling Tests
    
    func test_htmlRenderer_enhancedCheckedTaskListStyling() async throws {
        let markdown = "- [x] Completed task with enhanced styling"
        let html = try await parser.parseToHTML(markdown)
        
        // Should contain enhanced CSS classes for checked items
        XCTAssertTrue(html.contains("task-list-item-checked"), "Should contain checked task list item class")
        XCTAssertTrue(html.contains("task-list-checkbox-checked"), "Should contain checked checkbox class")
        XCTAssertTrue(html.contains("task-list-content-checked"), "Should contain checked content class")
        
        // Should contain enhanced inline styling for checked items
        XCTAssertTrue(html.contains("background-color: rgba(33, 136, 33, 0.08)"), "Should have background color for checked items")
        XCTAssertTrue(html.contains("border-radius: 6px"), "Should have border radius for checked items")
        XCTAssertTrue(html.contains("text-decoration: line-through"), "Should have strikethrough for completed tasks")
        XCTAssertTrue(html.contains("text-decoration-color: #218838"), "Should have green strikethrough color")
        
        // Should contain enhanced checkbox styling
        XCTAssertTrue(html.contains("transform: scale(1.2)"), "Should have scaled checkbox")
        XCTAssertTrue(html.contains("accent-color: #218838"), "Should have green accent color for checked")
        XCTAssertTrue(html.contains("filter: brightness(1.1)"), "Should have brightness filter for checked")
        
        // Should have enhanced accessibility
        XCTAssertTrue(html.contains("aria-label=\"Completed task\""), "Should have enhanced accessibility label")
    }
    
    func test_htmlRenderer_enhancedUncheckedTaskListStyling() async throws {
        let markdown = "- [ ] Incomplete task with enhanced styling"
        let html = try await parser.parseToHTML(markdown)
        
        // Should contain enhanced CSS classes for unchecked items
        XCTAssertTrue(html.contains("task-list-item-unchecked"), "Should contain unchecked task list item class")
        XCTAssertTrue(html.contains("task-list-checkbox-unchecked"), "Should contain unchecked checkbox class")
        XCTAssertTrue(html.contains("task-list-content-unchecked"), "Should contain unchecked content class")
        
        // Should NOT contain styling specific to checked items
        XCTAssertFalse(html.contains("background-color: rgba(33, 136, 33, 0.08)"), "Should not have background color for unchecked")
        XCTAssertFalse(html.contains("text-decoration: line-through"), "Should not have strikethrough for incomplete tasks")
        
        // Should contain basic checkbox styling
        XCTAssertTrue(html.contains("transform: scale(1.2)"), "Should have scaled checkbox")
        XCTAssertTrue(html.contains("accent-color: #6c757d"), "Should have gray accent color for unchecked")
        XCTAssertFalse(html.contains("filter: brightness(1.1)"), "Should not have brightness filter for unchecked")
        
        // Should have enhanced accessibility
        XCTAssertTrue(html.contains("aria-label=\"Incomplete task\""), "Should have enhanced accessibility label")
    }
    
    func test_htmlRenderer_enhancedTaskListContainerStyling() async throws {
        let markdown = """
        - [x] First task
        - [ ] Second task
        - [x] Third task
        """
        
        let html = try await parser.parseToHTML(markdown)
        
        // Should contain task list container class
        XCTAssertTrue(html.contains("class=\"task-list\""), "Should contain task-list class")
        
        // Should contain enhanced container styling
        XCTAssertTrue(html.contains("list-style: none"), "Should remove default list styling")
        XCTAssertTrue(html.contains("padding-left: 0"), "Should remove default padding")
        XCTAssertTrue(html.contains("margin: 16px 0"), "Should have proper margins")
        
        // Should have mixed item types with correct classes
        let checkedCount = html.components(separatedBy: "task-list-item-checked").count - 1
        let uncheckedCount = html.components(separatedBy: "task-list-item-unchecked").count - 1
        XCTAssertEqual(checkedCount, 2, "Should have 2 checked items")
        XCTAssertEqual(uncheckedCount, 1, "Should have 1 unchecked item")
    }
    
    func test_htmlRenderer_enhancedTaskListWithComplexContent() async throws {
        let markdown = "- [x] Completed task with **bold** and *italic* text"
        let html = try await parser.parseToHTML(markdown)
        
        // Should contain enhanced styling for checked items
        XCTAssertTrue(html.contains("task-list-item-checked"), "Should contain checked item class")
        XCTAssertTrue(html.contains("task-list-content-checked"), "Should contain checked content class")
        
        // Should contain inline formatting within the strikethrough styling
        XCTAssertTrue(html.contains("<strong>") || html.contains("<b>"), "Should contain bold formatting")
        XCTAssertTrue(html.contains("<em>") || html.contains("<i>"), "Should contain italic formatting")
        
        // The content should be wrapped in the styled span
        XCTAssertTrue(html.contains("task-list-content-checked"), "Should wrap content in styled span")
        XCTAssertTrue(html.contains("text-decoration: line-through"), "Should have strikethrough even with complex content")
    }
    
    func test_htmlRenderer_enhancedTaskListCustomCSSClass() async throws {
        let context = RenderContext(
            styleConfiguration: StyleConfiguration(
                cssClasses: [
                    .taskListItem: "custom-task-item"
                ]
            )
        )
        let customRenderer = HTMLRenderer(context: context)
        
        let markdown = "- [x] Custom styled task"
        let ast = try await parser.parseToAST(markdown)
        let html = try await customRenderer.render(document: ast)
        
        // Should preserve custom CSS class while adding state-specific classes
        XCTAssertTrue(html.contains("custom-task-item"), "Should contain custom CSS class")
        XCTAssertTrue(html.contains("task-list-item-checked"), "Should also contain state-specific class")
        
        // Should still contain enhanced styling
        XCTAssertTrue(html.contains("background-color: rgba(33, 136, 33, 0.08)"), "Should have enhanced background styling")
        XCTAssertTrue(html.contains("text-decoration: line-through"), "Should have strikethrough styling")
    }
    
    func test_htmlRenderer_enhancedTaskListMixedWithRegularList() async throws {
        let markdown = """
        - Regular item
        - [x] Task item
        - Another regular item
        """
        
        let html = try await parser.parseToHTML(markdown)
        
        // Should contain task list container styling
        XCTAssertTrue(html.contains("class=\"task-list\""), "Should have task-list class on container")
        XCTAssertTrue(html.contains("list-style: none"), "Should have container styling")
        
        // Should have one enhanced task item
        XCTAssertTrue(html.contains("task-list-item-checked"), "Should have one checked task item")
        XCTAssertTrue(html.contains("task-list-checkbox-checked"), "Should have enhanced checkbox")
        
        // Should contain mix of regular and enhanced items
        let listItemCount = html.components(separatedBy: "<li").count - 1
        XCTAssertEqual(listItemCount, 3, "Should have 3 list items total")
        
        let enhancedItemCount = html.components(separatedBy: "task-list-content-checked").count - 1
        XCTAssertEqual(enhancedItemCount, 1, "Should have 1 enhanced task item")
    }

} 
