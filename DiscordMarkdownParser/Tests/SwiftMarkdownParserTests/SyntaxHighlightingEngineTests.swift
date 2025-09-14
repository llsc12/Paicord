import XCTest
@testable import DiscordMarkdownParser

/// Test suite for syntax highlighting engines.
/// 
/// This test suite covers all syntax highlighting engines using Test-Driven Development (TDD).
/// Tests are written first, then implementations are created to pass the tests.
final class SyntaxHighlightingEngineTests: XCTestCase {
    
    // MARK: - Test Setup
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Core Protocol Tests
    
    func test_syntaxHighlightingEngine_protocol_requirements() async throws {
        // Test that engines conform to protocol requirements
        let engines: [SyntaxHighlightingEngine] = [
            JavaScriptSyntaxEngine(),
            TypeScriptSyntaxEngine(),
            SwiftSyntaxEngine(),
            KotlinSyntaxEngine(),
            PythonSyntaxEngine(),
            BashSyntaxEngine()
        ]
        
        for engine in engines {
            // Each engine should support at least one language
            XCTAssertFalse(engine.supportedLanguages().isEmpty, "Engine should support at least one language")
            
            // Each engine should be able to highlight empty code
            let emptyTokens = try await engine.highlight("", language: engine.supportedLanguages().first!)
            XCTAssertTrue(emptyTokens.isEmpty || emptyTokens.allSatisfy { $0.content.isEmpty })
        }
    }
    
    func test_syntaxToken_equality() {
        let token1 = SyntaxToken(content: "func", tokenType: .keyword, range: "func".startIndex..<"func".endIndex)
        let token2 = SyntaxToken(content: "func", tokenType: .keyword, range: "func".startIndex..<"func".endIndex)
        let token3 = SyntaxToken(content: "var", tokenType: .keyword, range: "var".startIndex..<"var".endIndex)
        
        XCTAssertEqual(token1, token2)
        XCTAssertNotEqual(token1, token3)
    }
    
    func test_syntaxTokenType_allCases() {
        // Ensure all token types are covered
        let expectedTypes: Set<SyntaxTokenType> = [
            .keyword, .string, .comment, .number, .identifier, .operator, .punctuation,
            .plain, .type, .function, .variable, .constant, .builtin, .attribute,
            .generic, .namespace, .property, .method, .parameter, .label, .escape,
            .interpolation, .regex, .template, .annotation, .modifier
        ]
        
        let actualTypes = Set(SyntaxTokenType.allCases)
        XCTAssertEqual(expectedTypes, actualTypes, "All token types should be defined")
    }
    
    // MARK: - Registry Tests
    
    func test_syntaxHighlightingRegistry_initialization() async {
        let registry = SyntaxHighlightingRegistry()
        let supportedLanguages = await registry.supportedLanguages()
        
        // Should support all primary languages
        let expectedLanguages: Set<String> = [
            "javascript", "js", "jsx", "typescript", "ts", "tsx",
            "swift", "kotlin", "kt", "python", "py",
            "bash", "sh", "shell", "zsh"
        ]
        
        for language in expectedLanguages {
            XCTAssertTrue(supportedLanguages.contains(language), "Should support \(language)")
        }
    }
    
    func test_syntaxHighlightingRegistry_engineRetrieval() async {
        let registry = SyntaxHighlightingRegistry()
        
        // Test engine retrieval for each language
        let testCases: [(String, SyntaxHighlightingEngine.Type)] = [
            ("javascript", JavaScriptSyntaxEngine.self),
            ("typescript", TypeScriptSyntaxEngine.self),
            ("swift", SwiftSyntaxEngine.self),
            ("kotlin", KotlinSyntaxEngine.self),
            ("python", PythonSyntaxEngine.self),
            ("bash", BashSyntaxEngine.self)
        ]
        
        for (language, expectedType) in testCases {
            let engine = await registry.engine(for: language)
            XCTAssertNotNil(engine, "Should have engine for \(language)")
            XCTAssertTrue(type(of: engine!) == expectedType, "Should return correct engine type for \(language)")
        }
        
        // Test unsupported language
        let unsupportedEngine = await registry.engine(for: "unsupported")
        XCTAssertNil(unsupportedEngine, "Should return nil for unsupported language")
    }
    
    // MARK: - Error Handling Tests
    
    func test_syntaxHighlightingError_types() {
        let errors: [SyntaxHighlightingError] = [
            .unsupportedLanguage("test"),
            .parsingError("test"),
            .cacheError("test"),
            .engineRegistrationError("test")
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription, "Error should have description")
        }
    }
    
    func test_engine_unsupportedLanguage_throwsError() async {
        let engine = JavaScriptSyntaxEngine()
        
        do {
            _ = try await engine.highlight("test", language: "unsupported")
            XCTFail("Should throw error for unsupported language")
        } catch SyntaxHighlightingError.unsupportedLanguage(let language) {
            XCTAssertEqual(language, "unsupported")
        } catch {
            XCTFail("Should throw SyntaxHighlightingError.unsupportedLanguage")
        }
    }
    
    // MARK: - Edge Case Tests
    
    func test_engines_handleEmptyStrings() async throws {
        let engines: [(SyntaxHighlightingEngine, String)] = [
            (SwiftSyntaxEngine(), "swift"),
            (PythonSyntaxEngine(), "python"),
            (JavaScriptSyntaxEngine(), "javascript"),
            (TypeScriptSyntaxEngine(), "typescript"),
            (KotlinSyntaxEngine(), "kotlin"),
            (BashSyntaxEngine(), "bash")
        ]
        
        for (engine, language) in engines {
            let tokens = try await engine.highlight("", language: language)
            XCTAssertTrue(tokens.isEmpty, "\(language) engine should handle empty strings")
        }
    }
    
    func test_engines_handleVeryShortStrings() async throws {
        let engines: [(SyntaxHighlightingEngine, String)] = [
            (SwiftSyntaxEngine(), "swift"),
            (PythonSyntaxEngine(), "python"),
            (JavaScriptSyntaxEngine(), "javascript"),
            (TypeScriptSyntaxEngine(), "typescript"),
            (KotlinSyntaxEngine(), "kotlin"),
            (BashSyntaxEngine(), "bash")
        ]
        
        let testCases = ["a", "ab", "/", "//", "\"", "\"\"", "$", "/*", "*/", "@", "#"]
        
        for (engine, language) in engines {
            for testCase in testCases {
                do {
                    let tokens = try await engine.highlight(testCase, language: language)
                    // Should not crash and should return some tokens
                    XCTAssertTrue(tokens.count >= 0, "\(language) engine should handle '\(testCase)' without crashing")
                } catch {
                    XCTFail("\(language) engine should not throw error for '\(testCase)': \(error)")
                }
            }
        }
    }
    
    func test_engines_handleSingleCharacterStrings() async throws {
        let engines: [(SyntaxHighlightingEngine, String)] = [
            (SwiftSyntaxEngine(), "swift"),
            (PythonSyntaxEngine(), "python"),
            (JavaScriptSyntaxEngine(), "javascript"),
            (TypeScriptSyntaxEngine(), "typescript"),
            (KotlinSyntaxEngine(), "kotlin"),
            (BashSyntaxEngine(), "bash")
        ]
        
        // Test single characters that could cause index out of bounds
        let singleChars = ["/", "*", "\"", "'", "$", "@", "#", "\\", "(", ")", "[", "]", "{", "}", ".", ",", ";", ":", "?", "!", "&", "|", "^", "~", "+", "-", "=", "<", ">", "%"]
        
        for (engine, language) in engines {
            for char in singleChars {
                do {
                    let tokens = try await engine.highlight(char, language: language)
                    XCTAssertTrue(tokens.count >= 0, "\(language) engine should handle single character '\(char)' without crashing")
                } catch {
                    XCTFail("\(language) engine should not throw error for single character '\(char)': \(error)")
                }
            }
        }
    }
    
    func test_engines_handleUnclosedBlockComments() async throws {
        // Test for the specific bug where unclosed block comments extending to end of input
        // were incorrectly truncated by one character
        let testCases: [(SyntaxHighlightingEngine, String, String)] = [
            (KotlinSyntaxEngine(), "kotlin", "/* unclosed comment"),
            (KotlinSyntaxEngine(), "kotlin", "/* unclosed comment with more text"),
            (KotlinSyntaxEngine(), "kotlin", "/*a"),
            (TypeScriptSyntaxEngine(), "typescript", "/* unclosed comment"),
            (TypeScriptSyntaxEngine(), "typescript", "/* unclosed comment with more text"),
            (TypeScriptSyntaxEngine(), "typescript", "/*a"),
            (JavaScriptSyntaxEngine(), "javascript", "/* unclosed comment"),
            (SwiftSyntaxEngine(), "swift", "/* unclosed comment")
        ]
        
        for (engine, language, code) in testCases {
            do {
                let tokens = try await engine.highlight(code, language: language)
                
                // Find the comment token
                let commentTokens = tokens.filter { $0.tokenType == .comment }
                XCTAssertEqual(commentTokens.count, 1, "Should have exactly one comment token for '\(code)' in \(language)")
                
                if let commentToken = commentTokens.first {
                    // The comment token should include the entire input string
                    XCTAssertEqual(commentToken.content, code, "Comment token should include entire unclosed comment for '\(code)' in \(language)")
                }
            } catch {
                XCTFail("\(language) engine should not throw error for unclosed comment '\(code)': \(error)")
                         }
         }
     }
}

// MARK: - JavaScript Engine Tests

extension SyntaxHighlightingEngineTests {
    
    func test_javascriptEngine_highlightsKeywords() async throws {
        let engine = JavaScriptSyntaxEngine()
        let code = "function test() { const x = 42; }"
        let tokens = try await engine.highlight(code, language: "javascript")
        
        XCTAssertTrue(tokens.contains { $0.content == "function" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "const" && $0.tokenType == .keyword })
    }
    
    func test_javascriptEngine_highlightsES6Features() async throws {
        let engine = JavaScriptSyntaxEngine()
        let code = "const arrow = (x) => x * 2;"
        let tokens = try await engine.highlight(code, language: "javascript")
        
        XCTAssertTrue(tokens.contains { $0.content == "const" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "=>" && $0.tokenType == .`operator` })
    }
    
    func test_javascriptEngine_highlightsTemplateLiterals() async throws {
        let engine = JavaScriptSyntaxEngine()
        let code = "const msg = `Hello ${name}`;"
        let tokens = try await engine.highlight(code, language: "javascript")
        
        let templateTokens = tokens.filter { $0.tokenType == .template }
        let interpolationTokens = tokens.filter { $0.tokenType == .interpolation }
        
        XCTAssertFalse(templateTokens.isEmpty, "Should have template tokens")
        XCTAssertFalse(interpolationTokens.isEmpty, "Should have interpolation tokens")
    }
    
    func test_javascriptEngine_highlightsAsyncAwait() async throws {
        let engine = JavaScriptSyntaxEngine()
        let code = "async function fetch() { await api.get(); }"
        let tokens = try await engine.highlight(code, language: "javascript")
        
        XCTAssertTrue(tokens.contains { $0.content == "async" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "await" && $0.tokenType == .keyword })
    }
    
    func test_javascriptEngine_highlightsJSX() async throws {
        let engine = JavaScriptSyntaxEngine()
        let code = "const element = <div className='test'>{content}</div>;"
        let tokens = try await engine.highlight(code, language: "jsx")
        
        XCTAssertTrue(tokens.contains { $0.content == "className" && $0.tokenType == .attribute })
        XCTAssertTrue(tokens.contains { $0.content == "div" && $0.tokenType == .type })
    }
}

// MARK: - TypeScript Engine Tests

extension SyntaxHighlightingEngineTests {
    
    func test_typescriptEngine_highlightsTypeAnnotations() async throws {
        let engine = TypeScriptSyntaxEngine()
        let code = "function greet(name: string): void {}"
        let tokens = try await engine.highlight(code, language: "typescript")
        
        XCTAssertTrue(tokens.contains { $0.content == "string" && $0.tokenType == .type })
        XCTAssertTrue(tokens.contains { $0.content == "void" && $0.tokenType == .type })
    }
    
    func test_typescriptEngine_highlightsGenerics() async throws {
        let engine = TypeScriptSyntaxEngine()
        let code = "function identity<T>(arg: T): T { return arg; }"
        let tokens = try await engine.highlight(code, language: "typescript")
        
        XCTAssertTrue(tokens.contains { $0.content == "T" && $0.tokenType == .generic })
    }
    
    func test_typescriptEngine_highlightsInterfaces() async throws {
        let engine = TypeScriptSyntaxEngine()
        let code = "interface User { name: string; age?: number; }"
        let tokens = try await engine.highlight(code, language: "typescript")
        
        XCTAssertTrue(tokens.contains { $0.content == "interface" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "User" && $0.tokenType == .type })
    }
    
    func test_typescriptEngine_highlightsDecorators() async throws {
        let engine = TypeScriptSyntaxEngine()
        let code = "@Component({ selector: 'app' }) class App {}"
        let tokens = try await engine.highlight(code, language: "typescript")
        
        XCTAssertTrue(tokens.contains { $0.content == "@Component" && $0.tokenType == .attribute })
    }
}

// MARK: - Swift Engine Tests

extension SyntaxHighlightingEngineTests {
    
    func test_swiftEngine_highlightsModernSyntax() async throws {
        let engine = SwiftSyntaxEngine()
        let code = "func greet(name: String) async throws -> String {}"
        let tokens = try await engine.highlight(code, language: "swift")
        
        XCTAssertTrue(tokens.contains { $0.content == "func" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "async" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "throws" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "String" && $0.tokenType == .type })
    }
    
    func test_swiftEngine_highlightsPropertyWrappers() async throws {
        let engine = SwiftSyntaxEngine()
        let code = "@State private var count: Int = 0"
        let tokens = try await engine.highlight(code, language: "swift")
        
        XCTAssertTrue(tokens.contains { $0.content == "@State" && $0.tokenType == .attribute })
        XCTAssertTrue(tokens.contains { $0.content == "private" && $0.tokenType == .modifier })
        XCTAssertTrue(tokens.contains { $0.content == "var" && $0.tokenType == .keyword })
    }
    
    func test_swiftEngine_highlightsStringInterpolation() async throws {
        let engine = SwiftSyntaxEngine()
        let code = "let message = \"Hello \\(name)\""
        let tokens = try await engine.highlight(code, language: "swift")
        
        let interpolationTokens = tokens.filter { $0.tokenType == .interpolation }
        XCTAssertFalse(interpolationTokens.isEmpty, "Should have interpolation tokens")
    }
    
    func test_swiftEngine_highlightsClosures() async throws {
        let engine = SwiftSyntaxEngine()
        let code = "let numbers = [1, 2, 3].map { $0 * 2 }"
        let tokens = try await engine.highlight(code, language: "swift")
        
        XCTAssertTrue(tokens.contains { $0.content == "$0" && $0.tokenType == .parameter })
        XCTAssertTrue(tokens.contains { $0.content == "map" && $0.tokenType == .method })
    }
}

// MARK: - Kotlin Engine Tests

extension SyntaxHighlightingEngineTests {
    
    func test_kotlinEngine_highlightsDataClasses() async throws {
        let engine = KotlinSyntaxEngine()
        let code = "data class User(val name: String, var age: Int)"
        let tokens = try await engine.highlight(code, language: "kotlin")
        
        XCTAssertTrue(tokens.contains { $0.content == "data" && $0.tokenType == .modifier })
        XCTAssertTrue(tokens.contains { $0.content == "class" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "val" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "var" && $0.tokenType == .keyword })
    }
    
    func test_kotlinEngine_highlightsExtensionFunctions() async throws {
        let engine = KotlinSyntaxEngine()
        let code = "fun String.isEmail(): Boolean = this.contains('@')"
        let tokens = try await engine.highlight(code, language: "kotlin")
        
        XCTAssertTrue(tokens.contains { $0.content == "fun" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "String" && $0.tokenType == .type })
        XCTAssertTrue(tokens.contains { $0.content == "Boolean" && $0.tokenType == .type })
    }
    
    func test_kotlinEngine_highlightsCoroutines() async throws {
        let engine = KotlinSyntaxEngine()
        let code = "suspend fun fetch(): String = withContext(Dispatchers.IO) {}"
        let tokens = try await engine.highlight(code, language: "kotlin")
        
        XCTAssertTrue(tokens.contains { $0.content == "suspend" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "withContext" && $0.tokenType == .function })
    }
    
    func test_kotlinEngine_highlightsNullSafety() async throws {
        let engine = KotlinSyntaxEngine()
        let code = "val name: String? = user?.name ?: \"Unknown\""
        let tokens = try await engine.highlight(code, language: "kotlin")
        
        XCTAssertTrue(tokens.contains { $0.content == "?" && $0.tokenType == .`operator` })
        XCTAssertTrue(tokens.contains { $0.content == "?:" && $0.tokenType == .`operator` })
    }
}

// MARK: - Python Engine Tests

extension SyntaxHighlightingEngineTests {
    
    func test_pythonEngine_highlightsKeywords() async throws {
        let engine = PythonSyntaxEngine()
        let code = "def function(): pass"
        let tokens = try await engine.highlight(code, language: "python")
        
        XCTAssertTrue(tokens.contains { $0.content == "def" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "pass" && $0.tokenType == .keyword })
    }
    
    func test_pythonEngine_highlightsStrings() async throws {
        let engine = PythonSyntaxEngine()
        let code = "print('Hello \"World\"')"
        let tokens = try await engine.highlight(code, language: "python")
        
        let stringToken = tokens.first { $0.tokenType == .string }
        XCTAssertNotNil(stringToken)
    }
    
    func test_pythonEngine_highlightsBuiltins() async throws {
        let engine = PythonSyntaxEngine()
        let code = "print(len(range(10)))"
        let tokens = try await engine.highlight(code, language: "python")
        
        XCTAssertTrue(tokens.contains { $0.content == "print" && $0.tokenType == .builtin })
        XCTAssertTrue(tokens.contains { $0.content == "len" && $0.tokenType == .builtin })
        XCTAssertTrue(tokens.contains { $0.content == "range" && $0.tokenType == .builtin })
    }
    
    func test_pythonEngine_highlightsAsyncAwait() async throws {
        let engine = PythonSyntaxEngine()
        let code = "async def fetch(): await api.get()"
        let tokens = try await engine.highlight(code, language: "python")
        
        XCTAssertTrue(tokens.contains { $0.content == "async" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "await" && $0.tokenType == .keyword })
    }
}

// MARK: - Bash Engine Tests

extension SyntaxHighlightingEngineTests {
    
    func test_bashEngine_highlightsShebang() async throws {
        let engine = BashSyntaxEngine()
        let code = "#!/bin/bash\necho 'Hello'"
        let tokens = try await engine.highlight(code, language: "bash")
        
        XCTAssertTrue(tokens.contains { $0.content == "#!/bin/bash" && $0.tokenType == .comment })
    }
    
    func test_bashEngine_highlightsCommands() async throws {
        let engine = BashSyntaxEngine()
        let code = "ls -la\ngrep 'pattern' file.txt"
        let tokens = try await engine.highlight(code, language: "bash")
        
        XCTAssertTrue(tokens.contains { $0.content == "ls" && $0.tokenType == .builtin })
        XCTAssertTrue(tokens.contains { $0.content == "grep" && $0.tokenType == .builtin })
    }
    
    func test_bashEngine_highlightsVariables() async throws {
        let engine = BashSyntaxEngine()
        let code = "NAME='John'\necho $NAME"
        let tokens = try await engine.highlight(code, language: "bash")
        
        XCTAssertTrue(tokens.contains { $0.content == "$NAME" && $0.tokenType == .variable })
    }
    
    func test_bashEngine_highlightsControlStructures() async throws {
        let engine = BashSyntaxEngine()
        let code = "if [ $? -eq 0 ]; then echo 'success'; fi"
        let tokens = try await engine.highlight(code, language: "bash")
        
        XCTAssertTrue(tokens.contains { $0.content == "if" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "then" && $0.tokenType == .keyword })
        XCTAssertTrue(tokens.contains { $0.content == "fi" && $0.tokenType == .keyword })
    }
} 
