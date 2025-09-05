import XCTest

@testable import DiscordModels

class ValidatablePayloadTests: XCTestCase, @unchecked Sendable, ValidatablePayload {

    /// `ValidatablePayload` requirement
    func validate() -> [ValidationFailure] {}

    func testValidateAssertIsNotEmpty() throws {
        try validateAssertIsNotEmpty(true, name: "a").throw()
        XCTAssertThrowsError(
            try validateAssertIsNotEmpty(false, name: "a").throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, ValidationFailure.cantBeEmpty(name: "a"))
        }
    }

    func testValidateAtLeastOneIsNotEmpty() throws {
        try validateAtLeastOneIsNotEmpty(false, names: "a").throw()
        try validateAtLeastOneIsNotEmpty(nil, names: "a").throw()
        try validateAtLeastOneIsNotEmpty(false, true, names: "a").throw()
        try validateAtLeastOneIsNotEmpty(nil, true, names: "a").throw()
        try validateAtLeastOneIsNotEmpty(false, nil, true, names: "a").throw()
        try validateAtLeastOneIsNotEmpty(false, false, nil, nil, true, true, names: "a").throw()
        try validateAtLeastOneIsNotEmpty(nil, names: "a").throw()
        XCTAssertThrowsError(
            try validateAtLeastOneIsNotEmpty(true, names: "a").throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .atLeastOneFieldIsRequired(names: ["a"]))
        }
    }

    func testValidateCharacterCountDoesNotExceed() throws {
        /// Some characters are 2 unicode bytes.
        /// It's important to always use `char.unicodeScalars.count` instead of `char.count`.
        XCTAssertEqual("🇯🇵".count, 1)
        XCTAssertEqual("🇯🇵".unicodeScalars.count, 2)

        try validateCharacterCountDoesNotExceed(nil, max: 0, name: "a").throw()
        try validateCharacterCountDoesNotExceed(nil, max: 12, name: "a").throw()
        try validateCharacterCountDoesNotExceed("", max: 0, name: "a").throw()
        try validateCharacterCountDoesNotExceed("abcde", max: 5, name: "a").throw()
        try validateCharacterCountDoesNotExceed("🇯🇵", max: 2, name: "emoji").throw()
        XCTAssertThrowsError(
            try validateCharacterCountDoesNotExceed("🇯🇵", max: 1, name: "emoji").throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .tooManyCharacters(name: "emoji", max: 1))
        }
        XCTAssertThrowsError(
            try validateCharacterCountDoesNotExceed("abdcefghijk", max: 10, name: "a").throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .tooManyCharacters(name: "a", max: 10))
        }
    }

    func testValidateCharacterCountInRange() throws {
        try validateCharacterCountInRange(nil, min: 0, max: 0, name: "a").throw()
        try validateCharacterCountInRange(nil, min: 0, max: 12, name: "a").throw()
        try validateCharacterCountInRange("", min: 0, max: 0, name: "a").throw()
        try validateCharacterCountInRange("abcde", min: 5, max: 5, name: "a").throw()
        try validateCharacterCountInRange("🇯🇵", min: 1, max: 2, name: "emoji").throw()
        XCTAssertThrowsError(
            try validateCharacterCountInRange("🇯🇵", min: 3, max: 4, name: "emoji").throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .characterCountOutOfRange(name: "emoji", min: 3, max: 4))
        }
        XCTAssertThrowsError(
            try validateCharacterCountInRange("abdcefghijk", min: 20, max: 40, name: "a").throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .characterCountOutOfRange(name: "a", min: 20, max: 40))
        }
    }

    func testValidateElementCountInRange() throws {
        try validateElementCountInRange(
            Optional<[String]>.none,
            min: 0,
            max: 0,
            name: "a"
        ).throw()
        try validateElementCountInRange(
            Optional<[String]>.none,
            min: 0,
            max: 12,
            name: "a"
        ).throw()
        try validateElementCountInRange([String](), min: 0, max: 0, name: "a").throw()
        try validateElementCountInRange(
            ["a", "b", "c", "d", "e"],
            min: 5,
            max: 5,
            name: "a"
        ).throw()
        XCTAssertThrowsError(
            try validateElementCountInRange(
                ["a", "b", "d", "c", "e", "f", "g", "h", "i", "j", "k"],
                min: 20,
                max: 40,
                name: "a"
            ).throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .elementCountOutOfRange(name: "a", min: 20, max: 40))
        }
    }

    func testValidateCombinedCharacterCountDoesNotExceed() throws {
        try validateCombinedCharacterCountDoesNotExceed(nil, max: 0, names: "a").throw()
        try validateCombinedCharacterCountDoesNotExceed(nil, max: 1, names: "a").throw()
        try validateCombinedCharacterCountDoesNotExceed(0, max: 0, names: "a").throw()
        try validateCombinedCharacterCountDoesNotExceed(0, max: 1, names: "a").throw()
        try validateCombinedCharacterCountDoesNotExceed(5, max: 5, names: "a").throw()
        try validateCombinedCharacterCountDoesNotExceed(5_000, max: 5_000, names: "a").throw()
        XCTAssertThrowsError(
            try validateCombinedCharacterCountDoesNotExceed(5_001, max: 5_000, names: "a", "b").throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .tooManyCharacters(name: "a+b", max: 5_000))
        }
    }

    func testValidateElementCountDoesNotExceed() throws {
        try validateElementCountDoesNotExceed(Optional<[Never]>.none, max: 0, name: "a").throw()
        try validateElementCountDoesNotExceed(Optional<[String]>.none, max: 1, name: "a").throw()
        try validateElementCountDoesNotExceed([String](), max: 0, name: "a").throw()
        try validateElementCountDoesNotExceed([String](), max: 1, name: "a").throw()
        try validateElementCountDoesNotExceed([1, 2, 3, 4], max: 4, name: "a").throw()
        XCTAssertThrowsError(
            try validateElementCountDoesNotExceed([1, 2, 3, 4, 5], max: 4, name: "t").throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .tooManyElements(name: "t", max: 4))
        }
    }

    func testValidateOnlyContains() throws {
        typealias Field = StringBitField<Permission>?
        try validateOnlyContains(
            Field.none,
            name: "r",
            reason: "k",
            allowed: []
        ).throw()
        try validateOnlyContains(
            Field.none,
            name: "r",
            reason: "k",
            allowed: []
        ).throw()
        try validateOnlyContains(
            Field([.addReactions, .administrator, .attachFiles]),
            name: "r",
            reason: "k",
            allowed: [.addReactions, .administrator, .attachFiles]
        ).throw()
        let throwingField = Field([.addReactions, .connect, .administrator, .attachFiles])
        XCTAssertThrowsError(
            try validateOnlyContains(
                throwingField,
                name: "r",
                reason: "k",
                allowed: [.addReactions, .connect, .administrator]
            ).throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(
                error,
                .containsProhibitedValues(
                    name: "r",
                    reason: "k",
                    valuesRepresentation: "\(throwingField!)"
                )
            )
        }
    }

    func testValidateCaseInsensitivelyDoesNotContain() throws {
        try validateCaseInsensitivelyDoesNotContain(
            nil,
            name: "aaabbb",
            values: ["discord", "clyde"],
            reason: "res"
        ).throw()
        try validateCaseInsensitivelyDoesNotContain(
            "discor",
            name: "aaabbb",
            values: ["discord", "clyde"],
            reason: "res"
        ).throw()
        XCTAssertThrowsError(
            try validateCaseInsensitivelyDoesNotContain(
                "diScordclYde",
                name: "aabb",
                values: ["discord", "clyde"],
                reason: "rrr"
            ).throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(
                error,
                .containsProhibitedValues(
                    name: "aabb",
                    reason: "rrr",
                    valuesRepresentation: "\(["discord", "clyde"])"
                )
            )
        }
    }

    func testValidateHasPrecondition() throws {
        try validateHasPrecondition(
            condition: true,
            allowedIf: true,
            name: "qq",
            reason: "pji"
        ).throw()
        try validateHasPrecondition(
            condition: false,
            allowedIf: false,
            name: "qq",
            reason: "pji"
        ).throw()
        try validateHasPrecondition(
            condition: false,
            allowedIf: true,
            name: "qq",
            reason: "pji"
        ).throw()
        XCTAssertThrowsError(
            try validateHasPrecondition(
                condition: true,
                allowedIf: false,
                name: "qq",
                reason: "pji"
            ).throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .hasPrecondition(name: "qq", reason: "pji"))
        }
    }

    func testValidateNumberInRangeOrNil() throws {
        try validateNumberInRangeOrNil(1, min: 0, max: 21_600, name: "adoand").throw()
        try validateNumberInRangeOrNil(0, min: 0, max: 21_600, name: "").throw()
        try validateNumberInRangeOrNil(21_599, min: 0, max: 21_600, name: "qerqer").throw()
        try validateNumberInRangeOrNil(21_600.9, min: 0, max: 21_601, name: "kkdasd").throw()
        try validateNumberInRangeOrNil(997, min: 0, max: 998, name: "tt").throw()
        XCTAssertThrowsError(
            try validateNumberInRangeOrNil(9, min: 10, max: 21, name: "tt").throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(error, .numberOutOfRange(name: "tt", number: "9", min: "10", max: "21"))
        }
        XCTAssertThrowsError(
            try validateNumberInRangeOrNil(22, min: 10, max: 21, name: "c,axz").throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(
                error,
                .numberOutOfRange(name: "c,axz", number: "22", min: "10", max: "21")
            )
        }
        XCTAssertThrowsError(
            try validateNumberInRangeOrNil(-1_391_293, min: 10, max: 21, name: "rqerqrew").throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(
                error,
                .numberOutOfRange(name: "rqerqrew", number: "-1391293", min: "10", max: "21")
            )
        }
        XCTAssertThrowsError(
            try validateNumberInRangeOrNil(934_129_139, min: 10, max: 21, name: "oewo").throw()
        ) { error in
            let error = error as! ValidationError
            XCTAssertErrorsEqual(
                error,
                .numberOutOfRange(name: "oewo", number: "934129139", min: "10", max: "21")
            )
        }
    }

    func testValidationsThrowsMultiple() throws {
        let embed = Embed(
            title: String(repeating: "a", count: 257),
            author: .init(name: String(repeating: "b", count: 256)),
            fields: .init(repeating: .init(name: "a", value: "b"), count: 26)
        )
        XCTAssertThrowsError(try embed.validate().throw(model: embed)) { error in
            let error = error as! ValidationError
            XCTAssertEqual("\(error.model)", "\(embed)")
            XCTAssertEqual(
                error.failures,
                [
                    .tooManyElements(name: "fields", max: 25),
                    .tooManyCharacters(name: "title", max: 256),
                ]
            )
        }
    }

    func XCTAssertErrorsEqual(
        _ expression1: ValidationError,
        _ expression2: ValidationFailure,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            expression1.failures.first!.description,
            expression2.description,
            line: line
        )
    }
}

extension ValidationFailure: Equatable {
    public static func == (lhs: ValidationFailure, rhs: ValidationFailure) -> Bool {
        "\(lhs)" == "\(rhs)"
    }
}

extension Optional where Wrapped == ValidationFailure {
    fileprivate func `throw`() throws {
        if let wrapped = self {
            /// `model` is not important for the tests.
            throw ValidationError(model: "", failures: [wrapped])
        }
    }
}
