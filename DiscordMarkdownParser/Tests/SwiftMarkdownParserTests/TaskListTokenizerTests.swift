import XCTest
@testable import DiscordMarkdownParser

/// Test-driven development tests for task list tokenization
/// 
/// These tests define the expected behavior for task list marker detection
/// at the tokenizer level, ensuring proper lexical analysis of task list syntax.
final class TaskListTokenizerTests: XCTestCase {
    
    // MARK: - Basic Task List Marker Tests
    
    func test_tokenizer_detectsCheckedTaskListMarker() {
        let input = "- [x] Completed task"
        let tokenizer = MarkdownTokenizer(input)
        let tokens = tokenizer.tokenize()
        
        // Expected tokens: listMarker, whitespace, taskListMarker, whitespace, text, whitespace, text, eof
        XCTAssertEqual(tokens.count, 8)
        XCTAssertEqual(tokens[0].type, .listMarker)
        XCTAssertEqual(tokens[0].content, "-")
        XCTAssertEqual(tokens[1].type, .whitespace)
        XCTAssertEqual(tokens[2].type, .taskListMarker)
        XCTAssertEqual(tokens[2].content, "[x]")
        XCTAssertEqual(tokens[3].type, .whitespace)
        XCTAssertEqual(tokens[4].type, .text)
        XCTAssertEqual(tokens[4].content, "Completed")
        XCTAssertEqual(tokens[5].type, .whitespace)
        XCTAssertEqual(tokens[6].type, .text)
        XCTAssertEqual(tokens[6].content, "task")
        XCTAssertEqual(tokens[7].type, .eof)
    }
    
    func test_tokenizer_detectsUncheckedTaskListMarker() {
        let input = "- [ ] Incomplete task"
        let tokenizer = MarkdownTokenizer(input)
        let tokens = tokenizer.tokenize()
        
        // Expected tokens: listMarker, whitespace, taskListMarker, whitespace, text, whitespace, text, eof
        XCTAssertEqual(tokens.count, 8)
        XCTAssertEqual(tokens[0].type, .listMarker)
        XCTAssertEqual(tokens[0].content, "-")
        XCTAssertEqual(tokens[1].type, .whitespace)
        XCTAssertEqual(tokens[2].type, .taskListMarker)
        XCTAssertEqual(tokens[2].content, "[ ]")
        XCTAssertEqual(tokens[3].type, .whitespace)
        XCTAssertEqual(tokens[4].type, .text)
        XCTAssertEqual(tokens[4].content, "Incomplete")
        XCTAssertEqual(tokens[5].type, .whitespace)
        XCTAssertEqual(tokens[6].type, .text)
        XCTAssertEqual(tokens[6].content, "task")
        XCTAssertEqual(tokens[7].type, .eof)
    }
    
    func test_tokenizer_detectsTaskListMarkerWithDifferentListMarkers() {
        let testCases = [
            ("- [x] With dash", "-"),
            ("+ [x] With plus", "+"),
            ("* [x] With asterisk", "*"),
            ("1. [x] With number", "1.")
        ]
        
        for (input, expectedListMarker) in testCases {
            let tokenizer = MarkdownTokenizer(input)
            let tokens = tokenizer.tokenize()
            
            XCTAssertGreaterThanOrEqual(tokens.count, 4, "Should have at least 4 tokens for: \(input)")
            XCTAssertEqual(tokens[0].type, .listMarker, "First token should be list marker for: \(input)")
            XCTAssertEqual(tokens[0].content, expectedListMarker, "List marker content should match for: \(input)")
            
            // Find the task list marker token
            let taskListToken = tokens.first { $0.type == .taskListMarker }
            XCTAssertNotNil(taskListToken, "Should find task list marker for: \(input)")
            XCTAssertEqual(taskListToken?.content, "[x]", "Task list marker should be [x] for: \(input)")
        }
    }
    
    // MARK: - Task List Marker Variations
    
    func test_tokenizer_detectsTaskListMarkerVariations() {
        let testCases = [
            ("- [x] Checked with x", "[x]"),
            ("- [X] Checked with X", "[X]"),
            ("- [ ] Unchecked with space", "[ ]"),
            ("- [o] Checked with o", "[o]"),
            ("- [O] Checked with O", "[O]"),
            ("- [v] Checked with v", "[v]"),
            ("- [V] Checked with V", "[V]")
        ]
        
        for (input, expectedMarker) in testCases {
            let tokenizer = MarkdownTokenizer(input)
            let tokens = tokenizer.tokenize()
            
            let taskListToken = tokens.first { $0.type == .taskListMarker }
            XCTAssertNotNil(taskListToken, "Should detect task list marker for: \(input)")
            XCTAssertEqual(taskListToken?.content, expectedMarker, "Task list marker should match for: \(input)")
        }
    }
    
    // MARK: - Edge Cases
    
    func test_tokenizer_ignoresInvalidTaskListMarkers() {
        let testCases = [
            "- [xx] Not a task list",  // Too many characters
            "- [] Empty brackets",     // Empty brackets
            "- [  ] Multiple spaces",  // Multiple spaces
            "- [ab] Invalid chars",    // Invalid characters
            "-[x] No space before",    // No space before brackets
            "- [x]No space after",     // No space after brackets (should still tokenize but differently)
        ]
        
        for input in testCases {
            let tokenizer = MarkdownTokenizer(input)
            let tokens = tokenizer.tokenize()
            
            // These should NOT produce taskListMarker tokens
            let hasTaskListMarker = tokens.contains { $0.type == .taskListMarker }
            XCTAssertFalse(hasTaskListMarker, "Should not detect task list marker for invalid input: \(input)")
        }
    }
    
    func test_tokenizer_handlesTaskListMarkerInMiddleOfLine() {
        let input = "Some text [x] in middle"
        let tokenizer = MarkdownTokenizer(input)
        let tokens = tokenizer.tokenize()
        
        // Should not detect task list marker in middle of line
        let hasTaskListMarker = tokens.contains { $0.type == .taskListMarker }
        XCTAssertFalse(hasTaskListMarker, "Should not detect task list marker in middle of line")
    }
    
    func test_tokenizer_handlesMultipleTaskListItems() {
        let input = """
        - [x] First task
        - [ ] Second task
        - [X] Third task
        """
        let tokenizer = MarkdownTokenizer(input)
        let tokens = tokenizer.tokenize()
        
        let taskListTokens = tokens.filter { $0.type == .taskListMarker }
        XCTAssertEqual(taskListTokens.count, 3, "Should detect 3 task list markers")
        XCTAssertEqual(taskListTokens[0].content, "[x]")
        XCTAssertEqual(taskListTokens[1].content, "[ ]")
        XCTAssertEqual(taskListTokens[2].content, "[X]")
    }
    
    // MARK: - Indentation Tests
    
    func test_tokenizer_handlesIndentedTaskLists() {
        let testCases = [
            ("  - [x] Indented 2 spaces", true),
            ("    - [x] Indented 4 spaces", true),
            ("      - [x] Indented 6 spaces", true),
            ("\t- [x] Indented with tab", true)
        ]
        
        for (input, shouldDetect) in testCases {
            let tokenizer = MarkdownTokenizer(input)
            let tokens = tokenizer.tokenize()
            
            let hasTaskListMarker = tokens.contains { $0.type == .taskListMarker }
            if shouldDetect {
                XCTAssertTrue(hasTaskListMarker, "Should detect task list marker for indented input: \(input)")
            } else {
                XCTAssertFalse(hasTaskListMarker, "Should not detect task list marker for: \(input)")
            }
        }
    }
    
    // MARK: - Source Location Tests
    
    func test_tokenizer_providesCorrectSourceLocations() {
        let input = "- [x] Task"
        let tokenizer = MarkdownTokenizer(input)
        let tokens = tokenizer.tokenize()
        
        let taskListToken = tokens.first { $0.type == .taskListMarker }
        XCTAssertNotNil(taskListToken)
        XCTAssertEqual(taskListToken?.location.line, 1)
        XCTAssertEqual(taskListToken?.location.column, 3) // After "- "
        XCTAssertEqual(taskListToken?.location.offset, 2) // After "- "
    }
    
    func test_tokenizer_providesCorrectLengthForTaskListMarkers() {
        let testCases = [
            ("[x]", 3),
            ("[ ]", 3),
            ("[X]", 3),
            ("[o]", 3)
        ]
        
        for (markerContent, expectedLength) in testCases {
            let input = "- \(markerContent) Task"
            let tokenizer = MarkdownTokenizer(input)
            let tokens = tokenizer.tokenize()
            
            let taskListToken = tokens.first { $0.type == .taskListMarker }
            XCTAssertNotNil(taskListToken)
            XCTAssertEqual(taskListToken?.length, expectedLength, "Length should match for marker: \(markerContent)")
            XCTAssertEqual(taskListToken?.content, markerContent, "Content should match for marker: \(markerContent)")
        }
    }
} 
