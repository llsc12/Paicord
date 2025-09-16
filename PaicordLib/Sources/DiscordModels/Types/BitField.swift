public protocol BitField: OptionSet, CustomStringConvertible where RawValue == UInt {
    associatedtype R: RawRepresentable & LosslessRawRepresentable
    where R: Hashable, R.RawValue == UInt
    var rawValue: UInt { get set }
}

extension BitField {

    /// Checks if the value exists in this `BitField`.
    public func contains(_ member: R) -> Bool {
        ((self.rawValue >> member.rawValue) & 1) == 1
    }

    /// Inserts a new value to the `BitField`.
    @discardableResult
    public mutating func insert(_ newMember: __owned R) -> (inserted: Bool, memberAfterInsert: R) {
        if self.contains(newMember) {
            return (inserted: false, memberAfterInsert: newMember)
        } else {
            self.rawValue |= (1 << newMember.rawValue)
            return (inserted: true, memberAfterInsert: newMember)
        }
    }

    /// Removes the value from the `BitField`.
    /// Returns the value if it existed at all.
    @discardableResult
    public mutating func remove(_ member: R) -> R? {
        if self.contains(member) {
            self.rawValue = self.rawValue - (1 << member.rawValue)
            return member
        } else {
            return nil
        }
    }

    /// The same as inserting a new value to the `BitField`.
    @discardableResult
    public mutating func update(with newMember: __owned R) -> R? {
        self.insert(newMember).memberAfterInsert
    }

    /// This `BitField`'s description.
    public var description: String {
        "\(Swift._typeName(Self.self))(rawValue: \(self.rawValue))"
    }

    /// Returns the `R` values in this bit field.
    public func representableValues() -> Set<R> {
        var bitValue = self.rawValue
        var values: [R] = []
        var counter: UInt = 0
        while bitValue != 0 {
            if (bitValue & 1) == 1 {
                /// `R` is ``LosslessRawRepresentable``. Safe to force-unwrap.
                values.append(R(rawValue: counter)!)
            }
            bitValue = bitValue >> 1
            counter += 1
        }
        return Set(values)
    }

    /// Creates a `BitField` from a `Sequence`.
    @inlinable
    public init(_ elements: some Sequence<R>) {
        self.init(
            rawValue:
                elements
                .map(\.rawValue)
                .map({ 1 << $0 })
                .reduce(into: 0, +=)
        )
    }

    /// Creates a `BitField` from the elements.
    @inlinable
    public init(arrayLiteral elements: R...) {
        self.init(elements)
    }
}

/// A bit-field that decode/encodes itself as an integer.
public struct IntBitField<R>: BitField
where R: RawRepresentable & LosslessRawRepresentable & Hashable, R.RawValue == UInt {
    public var rawValue: UInt

    public init(rawValue: UInt = 0) {
        self.rawValue = rawValue
    }
}

extension IntBitField: Codable {
    public init(from decoder: any Decoder) throws {
        self.rawValue = try UInt(from: decoder)
    }

    public func encode(to encoder: any Encoder) throws {
        try self.rawValue.encode(to: encoder)
    }
}

extension IntBitField: Sendable where R: Sendable {}

/// A bit-field that decode/encodes itself as a string.
public struct StringBitField<R>: BitField
where R: RawRepresentable & LosslessRawRepresentable & Hashable, R.RawValue == UInt {
    public var rawValue: UInt

    public init(rawValue: UInt = 0) {
        self.rawValue = rawValue
    }
}

extension StringBitField: Codable {

    public enum DecodingError: Error, CustomStringConvertible {
        /// The string value could not be converted to an integer. This is a library decoding issue, please report this at https://github.com/DiscordBM/DiscordBM/issues.
        case notRepresentingUInt(String)

        public var description: String {
            switch self {
            case let .notRepresentingUInt(string):
                return "StringBitField.DecodingError.notRepresentingUInt(\(string))"
            }
        }
    }

    public init(from decoder: any Decoder) throws {
        let string = try String(from: decoder)
        guard let int = UInt(string) else {
            throw DecodingError.notRepresentingUInt(string)
        }
        self.rawValue = int
    }

    public func encode(to encoder: any Encoder) throws {
        try "\(self.rawValue)".encode(to: encoder)
    }
}

extension StringBitField: Sendable where R: Sendable {}

//MARK: RangeReplaceableCollection + BitField
extension RangeReplaceableCollection {
    @inlinable
    public init<Field>(_ bitField: Field) where Field: BitField, Self.Element == Field.R {
        self.init(bitField.representableValues())
    }

    // Useful for optional-field conversions
    @inlinable
    public init?<Field>(_ bitField: Field?) where Field: BitField, Self.Element == Field.R {
        if let values = bitField?.representableValues() {
            self.init(values)
        } else {
            return nil
        }
    }
}
