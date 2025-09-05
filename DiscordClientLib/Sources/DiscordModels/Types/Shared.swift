import Foundation

//MARK: - StringIntDoubleBool

/// To dynamically decode/encode String or Int or Double or Bool.
public enum StringIntDoubleBool: Sendable, Codable {

    public enum Error: Swift.Error, CustomStringConvertible {
        case valueIsNotOfType(Any.Type, value: StringIntDoubleBool)

        public var description: String {
            switch self {
            case let .valueIsNotOfType(type, value):
                return "StringIntDoubleBool.Error.valueIsNotOfType(\(String(describing: type)), value: \(value))"
            }
        }
    }

    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)

    public var asString: String {
        switch self {
        case .string(let string): return string
        case .int(let int): return "\(int)"
        case .double(let double): return String(format: "%.2f", double)
        case .bool(let bool): return "\(bool)"
        }
    }

    /// Requires a `String` or throws `StringIntDoubleBool.Error`.
    @inlinable
    public func requireString() throws -> String {
        switch self {
        case .string(let string): return string
        default: throw Error.valueIsNotOfType(String.self, value: self)
        }
    }

    /// Requires a `Int` or throws `StringIntDoubleBool.Error`.
    @inlinable
    public func requireInt() throws -> Int {
        switch self {
        case .int(let int): return int
        default: throw Error.valueIsNotOfType(Int.self, value: self)
        }
    }

    /// Requires a `Double` or throws `StringIntDoubleBool.Error`.
    @inlinable
    public func requireDouble() throws -> Double {
        switch self {
        case .double(let double): return double
        default: throw Error.valueIsNotOfType(Double.self, value: self)
        }
    }

    /// Requires a `Bool` or throws `StringIntDoubleBool.Error`.
    @inlinable
    public func requireBool() throws -> Bool {
        switch self {
        case .bool(let bool): return bool
        default: throw Error.valueIsNotOfType(Bool.self, value: self)
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else {
            let double = try container.decode(Double.self)
            self = .double(double)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(string):
            try container.encode(string)
        case let .int(int):
            try container.encode(int)
        case let .double(double):
            try container.encode(double)
        case let .bool(bool):
            try container.encode(bool)
        }
    }
}

//MARK: - StringOrInt

/// To dynamically decode/encode String or Int.
public enum StringOrInt: Sendable, Codable {
    case string(String)
    case int(Int)

    public var asString: String {
        switch self {
        case .string(let string): return string
        case .int(let int): return "\(int)"
        }
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else {
            let int = try container.decode(Int.self)
            self = .int(int)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(string):
            try container.encode(string)
        case let .int(int):
            try container.encode(int)
        }
    }
}

//MARK: - IntOrDouble

public enum IntOrDouble: Sendable, Codable {
    case int(Int)
    case double(Double)

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else {
            let double = try container.decode(Double.self)
            self = .double(double)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .int(int):
            try container.encode(int)
        case let .double(double):
            try container.encode(double)
        }
    }
}

//MARK: - DiscordLocale

/// https://discord.com/developers/docs/reference#locales
@UnstableEnum<String>
public enum DiscordLocale: Sendable, Codable {
    case danish  // "da"
    case german  // "de"
    case englishUK  // "en-GB"
    case englishUS  // "en-US"
    case spanish  // "es-ES"
    case french  // "fr"
    case croatian  // "hr"
    case italian  // "it"
    case lithuanian  // "lt"
    case hungarian  // "hu"
    case dutch  // "nl"
    case norwegian  // "no"
    case polish  // "pl"
    case portuguese  // "pt-BR"
    case romanian  // "ro"
    case finnish  // "fi"
    case swedish  // "sv-SE"
    case vietnamese  // "vi"
    case turkish  // "tr"
    case czech  // "cs"
    case greek  // "el"
    case bulgarian  // "bg"
    case russian  // "ru"
    case ukrainian  // "uk"
    case hindi  // "hi"
    case thai  // "th"
    case chineseChina  // "zh-CN"
    case japanese  // "ja"
    case chineseTaiwan  // "zh-TW"
    case korean  // "ko"
    case __undocumented(String)
}

//MARK: - DiscordLocaleDict

/// A container to decode/encode `[DiscordLocale: String]`,
/// because Discord doesn't like how Codable decode/encodes `[DiscordLocale: String]`.
public struct DiscordLocaleDict<C: Codable>: Codable, ExpressibleByDictionaryLiteral {

    public var values: [DiscordLocale: C]

    public init(dictionaryLiteral elements: (DiscordLocale, C)...) {
        self.values = .init(elements, uniquingKeysWith: { l, _ in l })
    }

    public init(_ elements: [DiscordLocale: C]) {
        self.values = elements
    }

    public init?(_ elements: [DiscordLocale: C]?) {
        guard let elements else { return nil }
        self.values = elements
    }

    public init(from decoder: any Decoder) throws {
        let stringKeyedDict = try [String: C].init(from: decoder)
        self.values = [:]
        self.values.reserveCapacity(stringKeyedDict.count)
        for (key, value) in consume stringKeyedDict {
            /// Force-unwrap because ``DiscordLocale`` is ``LosslessRawRepresentable``.
            self.values[DiscordLocale(rawValue: key)!] = value
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var stringKeyedDict = [String: C]()
        stringKeyedDict.reserveCapacity(self.values.count)
        for (key, value) in self.values {
            stringKeyedDict[key.rawValue] = value
        }
        try stringKeyedDict.encode(to: encoder)
    }
}

extension DiscordLocaleDict: Sendable where C: Sendable {}

//MARK: - DiscordTimestamp

/// A timestamp that decode/encodes itself how Discord expects.
public struct DiscordTimestamp: Codable {

    public enum DecodingError: Swift.Error, CustomStringConvertible {
        /// The timestamp had an unexpected format. This is a library decoding issue, please report this at https://github.com/DiscordBM/DiscordBM/issues.
        case unexpectedFormat([any CodingKey], String)
        /// Could not convert the timestamp to a 'Date'. This is a library decoding issue, please report this at https://github.com/DiscordBM/DiscordBM/issues.
        case conversionFailure([any CodingKey], String, DateComponents)

        public var description: String {
            switch self {
            case let .unexpectedFormat(codingKey, timestamp):
                return "DiscordTimestamp.DecodingError.unexpectedFormat(\(codingKey), \(timestamp))"
            case let .conversionFailure(codingKey, timestamp, components):
                return "DiscordTimestamp.DecodingError.conversionFailure(\(codingKey), \(timestamp), \(components))"
            }
        }
    }

    public var date: Date

    public init(date: Date) {
        self.date = date
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        let startIndex = string.startIndex
        func index(_ offset: Int) -> String.Index {
            string.index(startIndex, offsetBy: offset)
        }

        let components: DateComponents

        if string.count == 32 {
            guard let year = Int(string[startIndex...index(3)]),
                let month = Int(string[index(5)...index(6)]),
                let day = Int(string[index(8)...index(9)]),
                let hour = Int(string[index(11)...index(12)]),
                let minute = Int(string[index(14)...index(15)]),
                let second = Int(string[index(17)...index(18)]),
                let microSecond = Int(string[index(20)...index(25)])
            else {
                throw DecodingError.unexpectedFormat(container.codingPath, string)
            }
            components = DateComponents(
                calendar: .utc,
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second,
                nanosecond: microSecond * 1_000
            )
        } else if string.count == 25 {
            guard let year = Int(string[startIndex...index(3)]),
                let month = Int(string[index(5)...index(6)]),
                let day = Int(string[index(8)...index(9)]),
                let hour = Int(string[index(11)...index(12)]),
                let minute = Int(string[index(14)...index(15)]),
                let second = Int(string[index(17)...index(18)])
            else {
                throw DecodingError.unexpectedFormat(container.codingPath, string)
            }
            components = DateComponents(
                calendar: .utc,
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second
            )
        } else {
            throw DecodingError.unexpectedFormat(container.codingPath, string)
        }
        guard let date = Calendar.utc.date(from: components) else {
            throw DecodingError.conversionFailure(container.codingPath, string, components)
        }
        self.date = date
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()

        let componentSet: Set<Calendar.Component> = [
            .year, .month, .day, .hour, .minute, .second, .nanosecond,
        ]
        let components = Calendar.utc.dateComponents(componentSet, from: date)
        guard let year = components.year,
            let month = components.month,
            let day = components.day,
            let hour = components.hour,
            let minute = components.minute,
            let second = components.second,
            let nanoSecond = components.nanosecond
        else {
            throw EncodingError.invalidValue(
                date,
                .init(
                    codingPath: container.codingPath,
                    debugDescription:
                        "Programming Error. Could not encode Date '\(date.debugDescription)' to Discord Timestamp. Please report: https://github.com/DiscordBM/DiscordBM/issues"
                )
            )
        }
        let miliSecond = nanoSecond / 1_000

        func fixedDigit(_ int: Int, _ length: Int) -> String {
            let description = "\(int)"
            let zeroCount = length - description.count
            if zeroCount > 0 {
                return String(repeating: "0", count: zeroCount) + description
            } else {
                return description
            }
        }

        let f = (
            year: fixedDigit(year, 4),
            month: fixedDigit(month, 2),
            day: fixedDigit(day, 2),
            hour: fixedDigit(hour, 2),
            minute: fixedDigit(minute, 2),
            second: fixedDigit(second, 2),
            mili: fixedDigit(miliSecond, 6)
        )

        let str = "\(f.year)-\(f.month)-\(f.day)T\(f.hour):\(f.minute):\(f.second).\(f.mili)+00:00"

        try container.encode(str)
    }
}

extension DiscordTimestamp: Sendable {}

//MARK: - IntPair

/// An array consisting of two integers.
public struct IntPair: Sendable, Codable, CustomStringConvertible {
    public var first: Int
    public var second: Int

    public var description: String {
        "(\(self.first), \(self.second))"
    }

    public init(_ first: Int, _ second: Int) {
        self.first = first
        self.second = second
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let array = try container.decode([Int].self)
        guard array.count == 2 else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Expected 2 integers in \(array.debugDescription)"
                )
            )
        }
        self.first = array[0]
        self.second = array[1]
    }

    public func encode(to encoder: any Encoder) throws {
        try [first, second].encode(to: encoder)
    }
}

//MARK: - DiscordColor

/// A dynamic color type that decode/encodes itself as an integer which Discord expects.
public struct DiscordColor: Sendable, Codable, Equatable, ExpressibleByIntegerLiteral {

    public let value: Int

    public func asRGB() -> (red: Int, green: Int, blue: Int) {
        let red = value >> 16
        let green = (value >> 8) & 0x00FF
        let blue = value & 0x0000FF
        return (red, green, blue)
    }

    public func asHex() -> String {
        "#" + String(self.value, radix: 16, uppercase: true)
    }

    public init(integerLiteral value: Int) {
        self.init(value: value)!
    }

    public init?(value: Int) {
        guard value >= 0,
            value < (1 << 24)
        else { return nil }
        self.value = value
    }

    init(_unvalidatedValue: Int) {
        self.value = _unvalidatedValue
    }

    static func unvalidatedRGB(red: Int, green: Int, blue: Int) -> DiscordColor {
        self.init(_unvalidatedValue: red << 16 | green << 8 | blue)
    }

    public init?(red: Int, green: Int, blue: Int) {
        guard (0..<256).contains(red),
            (0..<256).contains(green),
            (0..<256).contains(blue)
        else { return nil }
        self.value = red << 16 | green << 8 | blue
    }

    public init?(hex: String) {
        var dropCount = 0
        if hex.hasPrefix("#") {
            dropCount = 1
        }
        guard let value = Int(hex.dropFirst(dropCount), radix: 16) else {
            return nil
        }
        self.value = value
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(Int.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}

extension DiscordColor {

    /// Light mode or dark mode.
    public enum ColorScheme {
        case light
        case dark
    }

    /// iOS system red color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static func red(scheme: ColorScheme = .light) -> DiscordColor {
        switch scheme {
        case .light:
            return DiscordColor.unvalidatedRGB(red: 255, green: 59, blue: 48)
        case .dark:
            return DiscordColor.unvalidatedRGB(red: 255, green: 69, blue: 58)
        }
    }

    /// iOS system orange color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static func orange(scheme: ColorScheme = .light) -> DiscordColor {
        switch scheme {
        case .light:
            return DiscordColor.unvalidatedRGB(red: 255, green: 149, blue: 0)
        case .dark:
            return DiscordColor.unvalidatedRGB(red: 255, green: 159, blue: 10)
        }
    }

    /// iOS system yellow color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static func yellow(scheme: ColorScheme = .light) -> DiscordColor {
        switch scheme {
        case .light:
            return DiscordColor.unvalidatedRGB(red: 255, green: 204, blue: 0)
        case .dark:
            return DiscordColor.unvalidatedRGB(red: 255, green: 214, blue: 10)
        }
    }

    /// iOS system green color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static func green(scheme: ColorScheme = .light) -> DiscordColor {
        switch scheme {
        case .light:
            return DiscordColor.unvalidatedRGB(red: 52, green: 199, blue: 89)
        case .dark:
            return DiscordColor.unvalidatedRGB(red: 48, green: 209, blue: 88)
        }
    }

    /// iOS system mint color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static func mint(scheme: ColorScheme = .light) -> DiscordColor {
        switch scheme {
        case .light:
            return DiscordColor.unvalidatedRGB(red: 0, green: 199, blue: 190)
        case .dark:
            return DiscordColor.unvalidatedRGB(red: 99, green: 230, blue: 226)
        }
    }

    /// iOS system teal color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static func teal(scheme: ColorScheme = .light) -> DiscordColor {
        switch scheme {
        case .light:
            return DiscordColor.unvalidatedRGB(red: 48, green: 176, blue: 199)
        case .dark:
            return DiscordColor.unvalidatedRGB(red: 64, green: 200, blue: 224)
        }
    }

    /// iOS system cyan color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static func cyan(scheme: ColorScheme = .light) -> DiscordColor {
        switch scheme {
        case .light:
            return DiscordColor.unvalidatedRGB(red: 50, green: 173, blue: 230)
        case .dark:
            return DiscordColor.unvalidatedRGB(red: 100, green: 210, blue: 255)
        }
    }

    /// iOS system blue color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static func blue(scheme: ColorScheme = .light) -> DiscordColor {
        switch scheme {
        case .light:
            return DiscordColor.unvalidatedRGB(red: 0, green: 122, blue: 255)
        case .dark:
            return DiscordColor.unvalidatedRGB(red: 10, green: 132, blue: 255)
        }
    }

    /// iOS system indigo color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static func indigo(scheme: ColorScheme = .light) -> DiscordColor {
        switch scheme {
        case .light:
            return DiscordColor.unvalidatedRGB(red: 88, green: 86, blue: 214)
        case .dark:
            return DiscordColor.unvalidatedRGB(red: 94, green: 92, blue: 230)
        }
    }

    /// iOS system purple color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static func purple(scheme: ColorScheme = .light) -> DiscordColor {
        switch scheme {
        case .light:
            return DiscordColor.unvalidatedRGB(red: 175, green: 82, blue: 222)
        case .dark:
            return DiscordColor.unvalidatedRGB(red: 191, green: 90, blue: 242)
        }
    }

    /// iOS system pink color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static func pink(scheme: ColorScheme = .light) -> DiscordColor {
        switch scheme {
        case .light:
            return DiscordColor.unvalidatedRGB(red: 255, green: 45, blue: 85)
        case .dark:
            return DiscordColor.unvalidatedRGB(red: 255, green: 55, blue: 95)
        }
    }

    /// iOS system brown color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static func brown(scheme: ColorScheme = .light) -> DiscordColor {
        switch scheme {
        case .light:
            return DiscordColor.unvalidatedRGB(red: 165, green: 132, blue: 94)
        case .dark:
            return DiscordColor.unvalidatedRGB(red: 172, green: 142, blue: 104)
        }
    }

    /// iOS light system red color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static var red: DiscordColor { .red() }

    /// iOS light system orange color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static var orange: DiscordColor { .orange() }

    /// iOS light system yellow color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static var yellow: DiscordColor { .yellow() }

    /// iOS light system green color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static var green: DiscordColor { .green() }

    /// iOS light system mint color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static var mint: DiscordColor { .mint() }

    /// iOS light system teal color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static var teal: DiscordColor { .teal() }

    /// iOS light system cyan color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static var cyan: DiscordColor { .cyan() }

    /// iOS light system blue color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static var blue: DiscordColor { .blue() }

    /// iOS light system indigo color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static var indigo: DiscordColor { .indigo() }

    /// iOS light system purple color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static var purple: DiscordColor { .purple() }

    /// iOS light system pink color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static var pink: DiscordColor { .pink() }

    /// iOS light system brown color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-colors
    public static var brown: DiscordColor { .brown() }

    /// iOS light system gray1 color.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-gray-colors
    public static var gray: DiscordColor { .gray() }

    /// The gray levels in Apple's color HIG.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-gray-colors
    public enum ColorLevel {
        case level1
        case level2
        case level3
        case level4
        case level5
        case level6
    }

    /// iOS system gray colors.
    /// https://developer.apple.com/design/human-interface-guidelines/color#iOS-iPadOS-system-gray-colors
    public static func gray(
        level: ColorLevel = .level1,
        scheme: ColorScheme = .light
    ) -> DiscordColor {
        switch scheme {
        case .light:
            switch level {
            case .level1:
                return DiscordColor.unvalidatedRGB(red: 142, green: 142, blue: 147)
            case .level2:
                return DiscordColor.unvalidatedRGB(red: 174, green: 174, blue: 178)
            case .level3:
                return DiscordColor.unvalidatedRGB(red: 199, green: 199, blue: 204)
            case .level4:
                return DiscordColor.unvalidatedRGB(red: 209, green: 209, blue: 214)
            case .level5:
                return DiscordColor.unvalidatedRGB(red: 229, green: 229, blue: 234)
            case .level6:
                return DiscordColor.unvalidatedRGB(red: 242, green: 242, blue: 247)
            }
        case .dark:
            switch level {
            case .level1:
                return DiscordColor.unvalidatedRGB(red: 142, green: 142, blue: 147)
            case .level2:
                return DiscordColor.unvalidatedRGB(red: 99, green: 99, blue: 102)
            case .level3:
                return DiscordColor.unvalidatedRGB(red: 72, green: 72, blue: 74)
            case .level4:
                return DiscordColor.unvalidatedRGB(red: 58, green: 58, blue: 60)
            case .level5:
                return DiscordColor.unvalidatedRGB(red: 44, green: 44, blue: 46)
            case .level6:
                return DiscordColor.unvalidatedRGB(red: 28, green: 28, blue: 30)
            }
        }
    }
}

//MARK: - Secret

/// A type that will try to keep its content a secret when used with string interpolation.
/// This is to stop leaking something like a token in somewhere like the logs.
public struct Secret:
    Sendable,
    Codable,
    ExpressibleByStringLiteral,
    CustomStringConvertible,
    CustomDebugStringConvertible
{

    public var value: String

    public init(stringLiteral value: String) {
        self.value = value
    }

    public init(_ value: String) {
        self.value = value
    }

    public var description: String {
        let count = Swift.min((self.value.unicodeScalars.count / 4), 6)
        let prefixed = value.prefix(count)
        return #"Secret("\#(prefixed)****")"#
    }

    public var debugDescription: String {
        self.description
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}

//MARK: - DereferenceBox

/// A class so we can use the same type recursively in itself.
@dynamicMemberLookup
public final class DereferenceBox<C>: Codable where C: Codable {
    public let value: C

    public init(value: C) {
        self.value = value
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<C, T>) -> T {
        self.value[keyPath: keyPath]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(C.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}

extension DereferenceBox: Sendable where C: Sendable {}

//MARK: +Calendar

extension Calendar {
    #if compiler(>=5.10) && compiler(<6.0)
    /// It's safe the way DiscordBM uses it.
    nonisolated(unsafe) static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .init(identifier: "UTC")!
        return calendar
    }()
    #else
    static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .init(identifier: "UTC")!
        return calendar
    }()
    #endif
}
