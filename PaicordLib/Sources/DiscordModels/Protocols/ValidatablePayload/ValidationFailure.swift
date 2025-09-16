public enum ValidationFailure: Sendable, CustomStringConvertible {
    /// At least one of these fields is required to be present.
    case atLeastOneFieldIsRequired(names: [String])
    /// Too many characters in the target (likely a String). Need to shorten it.
    case tooManyCharacters(name: String, max: Int)
    /// Count of characters in the target (likely a String) is not acceptable.
    case characterCountOutOfRange(name: String, min: Int, max: Int)
    /// Too many elements in the target (likely an Array). Need to shorten it.
    case tooManyElements(name: String, max: Int)
    /// Count of elements in the target is not acceptable.
    case elementCountOutOfRange(name: String, min: Int, max: Int)
    /// At least one of the values you are trying to send is prohibited. Remove them.
    case containsProhibitedValues(name: String, reason: String, valuesRepresentation: String)
    /// Precondition needs to be met first.
    case hasPrecondition(name: String, reason: String)
    /// Field can't be empty.
    case cantBeEmpty(name: String)
    /// The number is too big or too small.
    case numberOutOfRange(name: String, number: String, min: String, max: String)

    public var description: String {
        switch self {
        case let .atLeastOneFieldIsRequired(names):
            return "ValidationFailure.atLeastOneFieldIsRequired(names: \(names))"
        case let .tooManyCharacters(name, max):
            return "ValidationFailure.tooManyCharacters(name: \(name), max: \(max))"
        case let .characterCountOutOfRange(name, min, max):
            return "ValidationFailure.characterCountOutOfRange(name: \(name), min: \(min), max: \(max))"
        case let .tooManyElements(name, max):
            return "ValidationFailure.tooManyElements(name: \(name), max: \(max))"
        case let .elementCountOutOfRange(name, min, max):
            return "ValidationFailure.elementCountOutOfRange(name: \(name), min: \(min), max: \(max))"
        case let .containsProhibitedValues(name, reason, valuesRepresentation):
            return
                "ValidationFailure.containsProhibitedValues(name: \(name), reason: \(reason), valuesRepresentation: \(valuesRepresentation))"
        case let .hasPrecondition(name, reason):
            return "ValidationFailure.hasPrecondition(name: \(name), reason: \(reason))"
        case let .cantBeEmpty(name):
            return "ValidationFailure.cantBeEmpty(name: \(name))"
        case let .numberOutOfRange(name, number, min, max):
            return "ValidationFailure.numberOutOfRange(name: \(name), number: \(number), min: \(min), max: \(max))"
        }
    }
}

extension [ValidationFailure] {
    /// Throws a `ValidationError` if any `ValidationFailure`s are available.
    /// - Parameter model: The data to be reported for debugging in case of throw.
    public func `throw`(model: any Sendable) throws {
        if !self.isEmpty {
            throw ValidationError(model: model, failures: self)
        }
    }
}
