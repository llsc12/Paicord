struct EnumCase {
  let key: String
  let value: String

  func maybeQuotedValue(rawType: RawKind) -> String {
    switch rawType {
    case .Int, .UInt, .UInt8, .UInt64, .Int64:
      return value
    case .String:
      return #""\#(value)""#
    }
  }
}
