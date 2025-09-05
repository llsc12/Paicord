import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import UnstableEnumMacro
import XCTest

class UnstableEnumMacroTests: XCTestCase {

    let macros: [String: any Macro.Type] = [
        "UnstableEnum": UnstableEnum.self
    ]

    func testStringEnum() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum: RawRepresentable {
                case a
                case b // bb
                case __undocumented(String)
            }
            """,
            expandedSource: """

                enum MyEnum: RawRepresentable {
                    case a
                    case b // bb
                    case __undocumented(String)

                    var rawValue: String {
                        switch self {
                        case .a:
                            return "a"
                        case .b:
                            return "bb"
                        case let .__undocumented(rawValue):
                            return rawValue
                        }
                    }

                    init?(rawValue: String) {
                        switch rawValue {
                        case "a":
                            self = .a
                        case "bb":
                            self = .b
                        default:
                            self = .__undocumented(rawValue)
                        }
                    }
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """,
            macros: macros
        )

        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum {
                case a
                case b // bb
                case __undocumented(String)
            }
            """,
            expandedSource: """

                enum MyEnum {
                    case a
                    case b // bb
                    case __undocumented(String)

                    var rawValue: String {
                        switch self {
                        case .a:
                            return "a"
                        case .b:
                            return "bb"
                        case let .__undocumented(rawValue):
                            return rawValue
                        }
                    }

                    init?(rawValue: String) {
                        switch rawValue {
                        case "a":
                            self = .a
                        case "bb":
                            self = .b
                        default:
                            self = .__undocumented(rawValue)
                        }
                    }
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """,
            macros: macros
        )

        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum: RawRepresentable {
                case a // "oo"
                case b // "bb"
                case __undocumented(String)
            }
            """,
            expandedSource: """

                enum MyEnum: RawRepresentable {
                    case a // "oo"
                    case b // "bb"
                    case __undocumented(String)

                    var rawValue: String {
                        switch self {
                        case .a:
                            return "oo"
                        case .b:
                            return "bb"
                        case let .__undocumented(rawValue):
                            return rawValue
                        }
                    }

                    init?(rawValue: String) {
                        switch rawValue {
                        case "oo":
                            self = .a
                        case "bb":
                            self = .b
                        default:
                            self = .__undocumented(rawValue)
                        }
                    }
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """,
            macros: macros
        )
    }

    func testIntEnum() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<Int>
            enum MyEnum: RawRepresentable {
                case a // 1
                case b // 5
                case __undocumented(Int)
            }
            """,
            expandedSource: """

                enum MyEnum: RawRepresentable {
                    case a // 1
                    case b // 5
                    case __undocumented(Int)

                    var rawValue: Int {
                        switch self {
                        case .a:
                            return 1
                        case .b:
                            return 5
                        case let .__undocumented(rawValue):
                            return rawValue
                        }
                    }

                    init?(rawValue: Int) {
                        switch rawValue {
                        case 1:
                            self = .a
                        case 5:
                            self = .b
                        default:
                            self = .__undocumented(rawValue)
                        }
                    }
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """,
            macros: macros
        )
    }

    func testDecodableEnum() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<Int>
            enum MyEnum: RawRepresentable, Codable {
                case a // 1
                case b // 5
                case __undocumented(Int)
            }
            """,
            expandedSource: #"""

                enum MyEnum: RawRepresentable, Codable {
                    case a // 1
                    case b // 5
                    case __undocumented(Int)

                    var rawValue: Int {
                        switch self {
                        case .a:
                            return 1
                        case .b:
                            return 5
                        case let .__undocumented(rawValue):
                            return rawValue
                        }
                    }

                    init?(rawValue: Int) {
                        switch rawValue {
                        case 1:
                            self = .a
                        case 5:
                            self = .b
                        default:
                            self = .__undocumented(rawValue)
                        }
                    }

                    init(from decoder: any Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        let rawValue = try container.decode(Int.self)
                        self.init(rawValue: rawValue)!
                        #if DISCORDBM_ENABLE_LOGGING_DURING_DECODE
                        if case let .__undocumented(rawValue) = self {
                            DiscordGlobalConfiguration.makeDecodeLogger("MyEnum").warning(
                                "Found an undocumented rawValue",
                                metadata: [
                                    "rawValue": "\(rawValue)",
                                    "typeName": "MyEnum",
                                    "location": "TestModule/test.swift:1",
                                ]
                            )
                        }
                        #endif
                    }
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """#,
            macros: macros
        )

        assertMacroExpansion(
            """
            @UnstableEnum<Int>
            enum MyEnum: RawRepresentable, Decodable, SomethingElse {
                case a // 1
                case b // 5
                case __undocumented(Int)
            }
            """,
            expandedSource: #"""

                enum MyEnum: RawRepresentable, Decodable, SomethingElse {
                    case a // 1
                    case b // 5
                    case __undocumented(Int)

                    var rawValue: Int {
                        switch self {
                        case .a:
                            return 1
                        case .b:
                            return 5
                        case let .__undocumented(rawValue):
                            return rawValue
                        }
                    }

                    init?(rawValue: Int) {
                        switch rawValue {
                        case 1:
                            self = .a
                        case 5:
                            self = .b
                        default:
                            self = .__undocumented(rawValue)
                        }
                    }

                    init(from decoder: any Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        let rawValue = try container.decode(Int.self)
                        self.init(rawValue: rawValue)!
                        #if DISCORDBM_ENABLE_LOGGING_DURING_DECODE
                        if case let .__undocumented(rawValue) = self {
                            DiscordGlobalConfiguration.makeDecodeLogger("MyEnum").warning(
                                "Found an undocumented rawValue",
                                metadata: [
                                    "rawValue": "\(rawValue)",
                                    "typeName": "MyEnum",
                                    "location": "TestModule/test.swift:1",
                                ]
                            )
                        }
                        #endif
                    }
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """#,
            macros: macros
        )
    }

    func testCaseIterableEnum() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum StringEnum: RawRepresentable, CaseIterable {
                case a
                case b
                case __undocumented(String)
            }
            """,
            expandedSource: #"""

                enum StringEnum: RawRepresentable, CaseIterable {
                    case a
                    case b
                    case __undocumented(String)

                    var rawValue: String {
                        switch self {
                        case .a:
                            return "a"
                        case .b:
                            return "b"
                        case let .__undocumented(rawValue):
                            return rawValue
                        }
                    }

                    init?(rawValue: String) {
                        switch rawValue {
                        case "a":
                            self = .a
                        case "b":
                            self = .b
                        default:
                            self = .__undocumented(rawValue)
                        }
                    }

                    static var allCases: [StringEnum] {
                        [
                            .a,
                            .b,
                        ]
                    }
                }

                extension StringEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """#,
            macros: macros
        )
    }

    func testKeepsPublicAccessModifier() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            public enum MyEnum: RawRepresentable {
                case a
                case b // bb
                case __undocumented(String)
            }
            """,
            expandedSource: """

                public enum MyEnum: RawRepresentable {
                    case a
                    case b // bb
                    case __undocumented(String)

                    public var rawValue: String {
                        switch self {
                        case .a:
                            return "a"
                        case .b:
                            return "bb"
                        case let .__undocumented(rawValue):
                            return rawValue
                        }
                    }

                    public init?(rawValue: String) {
                        switch rawValue {
                        case "a":
                            self = .a
                        case "bb":
                            self = .b
                        default:
                            self = .__undocumented(rawValue)
                        }
                    }
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """,
            macros: macros
        )
    }

    func testNestedEnum() throws {
        assertMacroExpansion(
            """
            extension N1.N2 {
                public enum N3 {
                    package struct N4 {
                        @UnstableEnum<String>
                        public enum MyEnum {
                            case a // "g"
                            case __undocumented
                        }
                    }
                }
            }
            """,
            expandedSource: #"""
                extension N1.N2 {
                    public enum N3 {
                        package struct N4 {
                            public enum MyEnum {
                                case a // "g"
                                case __undocumented

                                public var rawValue: String {
                                    switch self {
                                    case .a:
                                        return "g"
                                    case let .__undocumented(rawValue):
                                        return rawValue
                                    }
                                }

                                public init?(rawValue: String) {
                                    switch rawValue {
                                    case "g":
                                        self = .a
                                    default:
                                        self = .__undocumented(rawValue)
                                    }
                                }
                            }
                        }
                    }
                }

                extension N1.N2.N3.N4.MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """#,
            macros: macros
        )
    }

    func testBadIntEnum() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<Int>
            enum MyEnum: RawRepresentable {
                case a // 1
                case b
                case __undocumented(Int)
            }
            """,
            expandedSource: """

                enum MyEnum: RawRepresentable {
                    case a // 1
                    case b
                    case __undocumented(Int)
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """,
            diagnostics: [
                .init(
                    message: "allEnumCasesWithIntTypeMustHaveACommentForValue",
                    line: 4,
                    column: 10
                )
            ],
            macros: macros
        )
    }

    func testProgrammerErrorWrongArgumentType() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<Int>
            enum MyEnum: RawRepresentable {
                case a // bb
                case b // 1
                case __undocumented(Int)
            }
            """,
            expandedSource: """

                enum MyEnum: RawRepresentable {
                    case a // bb
                    case b // 1
                    case __undocumented(Int)
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """,
            diagnostics: [
                .init(
                    message: "intEnumMustOnlyHaveIntValues",
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )

        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum: RawRepresentable {
                case a // 2
                case b // 1
                case __undocumented(String)
            }
            """,
            expandedSource: """

                enum MyEnum: RawRepresentable {
                    case a // 2
                    case b // 1
                    case __undocumented(String)
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """,
            diagnostics: [
                .init(
                    message: "enumSeemsToHaveIntValuesButGenericArgumentSpecifiesString",
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )
    }

    func testInconsistentQuotes() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum: RawRepresentable {
                case a // a
                case b // "1
                case __undocumented(String)
            }
            """,
            expandedSource: """

                enum MyEnum: RawRepresentable {
                    case a // a
                    case b // "1
                    case __undocumented(String)
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """,
            diagnostics: [
                .init(
                    message: "inconsistentQuotesAroundComment",
                    line: 4,
                    column: 10
                )
            ],
            macros: macros
        )
    }

    func testValuesNotUnique() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum: RawRepresentable {
                case a // 1
                case b // 1
                case __undocumented(String)
            }
            """,
            expandedSource: """

                enum MyEnum: RawRepresentable {
                    case a // 1
                    case b // 1
                    case __undocumented(String)
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """,
            diagnostics: [
                .init(
                    message: "valuesMustBeUnique",
                    line: 1,
                    column: 1
                )
            ],
            macros: macros
        )
    }

    func testNoRawValues() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum: RawRepresentable {
                case a = "g"
                case b = "gg"
                case __undocumented(String)
            }
            """,
            expandedSource: """

                enum MyEnum: RawRepresentable {
                    case a = "g"
                    case b = "gg"
                    case __undocumented(String)
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """,
            diagnostics: [
                .init(
                    message: "rawValuesNotAcceptable",
                    line: 3,
                    column: 12,
                    fixIts: [.init(message: "useCommentsInstead")]
                ),
                .init(
                    message: "rawValuesNotAcceptable",
                    line: 4,
                    column: 12,
                    fixIts: [.init(message: "useCommentsInstead")]
                ),
            ],
            macros: macros
        )
    }

    func testRequireManualUndocumentedCase() throws {
        assertMacroExpansion(
            """
            @UnstableEnum<String>
            enum MyEnum: RawRepresentable {
                case a // "g"
                case b // "gg"
            }
            """,
            expandedSource: """

                enum MyEnum: RawRepresentable {
                    case a // "g"
                    case b // "gg"
                }

                extension MyEnum: RawRepresentable, LosslessRawRepresentable, Hashable {
                }
                """,
            diagnostics: [
                .init(
                    message: "lastCaseMustBe__undocumented",
                    line: 4,
                    column: 10
                )
            ],
            macros: macros
        )
    }

    func testEnumCodableWorks() async throws {
        let b = MyEnum.b
        let u = MyEnum.__undocumented(5)

        let b2 = try JSONEncoder().encode(b)
        let u2 = try JSONEncoder().encode(u)

        let b3 = try JSONDecoder().decode(MyEnum.self, from: b2)
        let u3 = try JSONDecoder().decode(MyEnum.self, from: u2)

        XCTAssertEqual(b3, b)
        XCTAssertEqual(u3, u)
    }
}

@UnstableEnum<Int>
enum MyEnum: Sendable, Codable {
    case a  // 1
    case b  // 7
    case c  // 9
    case __undocumented(Int)
}
