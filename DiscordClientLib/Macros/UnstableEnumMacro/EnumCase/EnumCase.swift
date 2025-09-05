struct EnumCase {
    let key: String
    let value: String

    func maybeQuotedValue(rawType: RawKind) -> String {
        switch rawType {
        case .Int, .UInt:
            return value
        case .String:
            return #""\#(value)""#
        }
    }
}
