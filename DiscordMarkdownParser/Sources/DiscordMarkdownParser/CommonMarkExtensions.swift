/// CommonMark specification compliance extensions
///
/// This file contains extensions and utilities to ensure strict CommonMark 0.30
/// specification compliance for edge cases and complex parsing scenarios.
import Foundation

// MARK: - CommonMark Utilities

/// Utilities for CommonMark specification compliance
public enum CommonMarkUtils {

  /// Check if a character is a Unicode whitespace character
  public static func isUnicodeWhitespace(_ char: Character) -> Bool {
    return char.isWhitespace
  }

  /// Check if a character is a punctuation character
  public static func isPunctuation(_ char: Character) -> Bool {
    return char.isPunctuation
      || "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~".contains(char)
  }

  /// Check if a character can start italic
  public static func canStartitalic(_ char: Character, leftFlanking: Bool)
    -> Bool
  {
    return leftFlanking && (char == "*")
  }

  /// Check if a character can end italic
  public static func canEnditalic(_ char: Character, rightFlanking: Bool)
    -> Bool
  {
    return rightFlanking && (char == "*")
  }

  /// Normalize line endings to \n
  public static func normalizeLineEndings(_ text: String) -> String {
    return
      text
      .replacingOccurrences(of: "\r\n", with: "\n")
      .replacingOccurrences(of: "\r", with: "\n")
  }

  /// Remove trailing whitespace from lines
  public static func removeTrailingWhitespace(_ text: String) -> String {
    return text.components(separatedBy: .newlines)
      .map { $0.trimmingCharacters(in: .whitespaces) }
      .joined(separator: "\n")
  }

  /// Check if a line is blank (contains only whitespace)
  public static func isBlankLine(_ line: String) -> Bool {
    return line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  /// Count leading spaces in a line
  public static func countLeadingSpaces(_ line: String) -> Int {
    var count = 0
    for char in line {
      if char == " " {
        count += 1
      } else {
        break
      }
    }
    return count
  }

  /// Check if a character sequence forms a valid thematic break
  public static func isThematicBreak(_ line: String) -> Bool {
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return false }

    let firstChar = trimmed.first!
    guard firstChar == "-" || firstChar == "*" || firstChar == "_" else {
      return false
    }

    var count = 0
    for char in trimmed {
      if char == firstChar {
        count += 1
      } else if char != " " && char != "\t" {
        return false
      }
    }

    return count >= 3
  }

  /// Extract ATX heading level and content
  public static func parseATXHeading(_ line: String) -> (
    level: Int, content: String
  )? {
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.hasPrefix("#") else { return nil }

    var level = 0
    var index = trimmed.startIndex

    // Count # characters
    while index < trimmed.endIndex && trimmed[index] == "#" && level < 6 {
      level += 1
      index = trimmed.index(after: index)
    }

    // Must be followed by space or end of line
    if index < trimmed.endIndex && !trimmed[index].isWhitespace {
      return nil
    }

    // Extract content
    let remaining = String(trimmed[index...]).trimmingCharacters(
      in: .whitespacesAndNewlines)
    let content = removeTrailingHashes(remaining)

    return (level: level, content: content)
  }

  /// Remove trailing # characters from heading content
  private static func removeTrailingHashes(_ content: String) -> String {
    var result = content

    // Remove trailing # characters if they're preceded by space
    while result.hasSuffix("#") && result.count > 1 {
      let beforeHash = result.dropLast()
      if beforeHash.last?.isWhitespace == true {
        result = String(beforeHash).trimmingCharacters(
          in: .whitespacesAndNewlines)
      } else {
        break
      }
    }

    return result
  }

  /// Check if a line is a valid setext heading underline
  public static func isSetextUnderline(_ line: String, for headingLevel: Int)
    -> Bool
  {
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return false }

    let char = headingLevel == 1 ? "=" : "-"
    return trimmed.allSatisfy { $0 == Character(char) }
  }

  /// Parse list marker and return type information
  public static func parseListMarker(_ line: String) -> ListMarkerInfo? {
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }

    let firstChar = trimmed.first!

    // Unordered list markers
    if firstChar == "-" || firstChar == "*" {
      if trimmed.count > 1 && trimmed.dropFirst().first?.isWhitespace == true {
        return ListMarkerInfo(
          isOrdered: false,
          marker: String(firstChar),
          number: nil,
          delimiter: nil,
          width: 1
        )
      }
    }

    // Ordered list markers
    if firstChar.isNumber {
      var numberStr = ""
      var index = trimmed.startIndex

      // Collect digits (max 9)
      while index < trimmed.endIndex && trimmed[index].isNumber
        && numberStr.count < 9
      {
        numberStr.append(trimmed[index])
        index = trimmed.index(after: index)
      }

      // Must be followed by . or )
      guard index < trimmed.endIndex else { return nil }
      let delimiter = trimmed[index]
      guard delimiter == "." else { return nil }

      index = trimmed.index(after: index)

      // Must be followed by whitespace or end of line
      if index < trimmed.endIndex && !trimmed[index].isWhitespace {
        return nil
      }

      if let number = Int(numberStr) {
        return ListMarkerInfo(
          isOrdered: true,
          marker: numberStr + String(delimiter),
          number: number,
          delimiter: delimiter,
          width: numberStr.count + 1
        )
      }
    }

    return nil
  }

  /// Check if two list markers are compatible
  public static func areListMarkersCompatible(
    _ marker1: ListMarkerInfo, _ marker2: ListMarkerInfo
  ) -> Bool {
    if marker1.isOrdered != marker2.isOrdered {
      return false
    }

    if marker1.isOrdered {
      return marker1.delimiter == marker2.delimiter
    } else {
      return marker1.marker == marker2.marker
    }
  }

  /// Calculate indentation for list continuation
  public static func calculateListIndentation(
    _ marker: ListMarkerInfo, leadingSpaces: Int
  ) -> Int {
    return leadingSpaces + marker.width + 1
  }
}

// MARK: - List Marker Info

/// Information about a parsed list marker
public struct ListMarkerInfo: Sendable, Equatable {
  /// Whether this is an ordered list marker
  public let isOrdered: Bool

  /// The raw marker text (e.g., "-", "1.", "2)")
  public let marker: String

  /// The number for ordered lists
  public let number: Int?

  /// The delimiter for ordered lists ('.')
  public let delimiter: Character?

  /// The width of the marker in characters
  public let width: Int
}

// MARK: - Enhanced Block Parser Extensions

extension BlockParser {

  /// Parse a line as a potential block element with CommonMark compliance
  func parseLineAsBlock(_ line: String, context: BlockParsingContext) throws
    -> BlockParseResult
  {
    let normalizedLine = CommonMarkUtils.normalizeLineEndings(line)
    let leadingSpaces = CommonMarkUtils.countLeadingSpaces(normalizedLine)

    // Check for blank line
    if CommonMarkUtils.isBlankLine(normalizedLine) {
      return .blankLine
    }

    // Check for thematic break
    if CommonMarkUtils.isThematicBreak(normalizedLine) {
      let char =
        normalizedLine.trimmingCharacters(in: .whitespacesAndNewlines).first
        ?? "-"
      return .thematicBreak(character: char)
    }

    // Check for ATX heading
    if let headingInfo = CommonMarkUtils.parseATXHeading(normalizedLine) {
      return .atxHeading(level: headingInfo.level, content: headingInfo.content)
    }

    // Check for list marker
    if let markerInfo = CommonMarkUtils.parseListMarker(normalizedLine) {
      let content = extractListItemContent(normalizedLine, marker: markerInfo)
      return .listItem(
        marker: markerInfo, content: content, indentation: leadingSpaces)
    }

    // Check for block quote
    if normalizedLine.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix(
      ">")
    {
      let content = extractBlockQuoteContent(normalizedLine)
      return .blockQuote(content: content)
    }

    // Check for code block (indented)
    if leadingSpaces >= 4 {
      let content = String(normalizedLine.dropFirst(4))
      return .indentedCodeBlock(content: content)
    }

    // Check for fenced code block
    if let fenceInfo = parseFencedCodeBlockStart(normalizedLine) {
      return .fencedCodeBlock(info: fenceInfo)
    }

    // Default to paragraph
    return .paragraph(
      content: normalizedLine.trimmingCharacters(in: .whitespacesAndNewlines))
  }

  private func extractListItemContent(_ line: String, marker: ListMarkerInfo)
    -> String
  {
    let afterMarker = line.dropFirst(
      CommonMarkUtils.countLeadingSpaces(line) + marker.width)
    return String(afterMarker).trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func extractBlockQuoteContent(_ line: String) -> String {
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.hasPrefix("> ") {
      return String(trimmed.dropFirst(2))
    } else if trimmed.hasPrefix(">") {
      return String(trimmed.dropFirst())
    }
    return trimmed
  }

  private func parseFencedCodeBlockStart(_ line: String) -> FencedCodeBlockInfo? {
    let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }

    let firstChar = trimmed.first!
    guard firstChar == "`" || firstChar == "~" else { return nil }

    var fenceLength = 0
    for char in trimmed {
      if char == firstChar {
        fenceLength += 1
      } else {
        break
      }
    }

    guard fenceLength >= 3 else { return nil }

    let infoString = String(trimmed.dropFirst(fenceLength)).trimmingCharacters(
      in: .whitespacesAndNewlines)
    let language = infoString.components(separatedBy: CharacterSet.whitespaces)
      .first

    return FencedCodeBlockInfo(
      character: firstChar,
      length: fenceLength,
      language: language,
      infoString: infoString
    )
  }
}

// MARK: - Supporting Types

/// Context for block parsing
public struct BlockParsingContext: Sendable {
  /// Current nesting level
  public let nestingLevel: Int

  /// Whether we're inside a list
  public let inList: Bool

  /// Current list marker if in list
  public let currentListMarker: ListMarkerInfo?

  /// Whether we're inside a block quote
  public let inBlockQuote: Bool

  public init(
    nestingLevel: Int = 0,
    inList: Bool = false,
    currentListMarker: ListMarkerInfo? = nil,
    inBlockQuote: Bool = false
  ) {
    self.nestingLevel = nestingLevel
    self.inList = inList
    self.currentListMarker = currentListMarker
    self.inBlockQuote = inBlockQuote
  }
}

/// Result of parsing a line as a block element
public enum BlockParseResult: Sendable {
  case blankLine
  case thematicBreak(character: Character)
  case atxHeading(level: Int, content: String)
  case setextHeading(level: Int, content: String)
  case listItem(marker: ListMarkerInfo, content: String, indentation: Int)
  case blockQuote(content: String)
  case indentedCodeBlock(content: String)
  case fencedCodeBlock(info: FencedCodeBlockInfo)
  case paragraph(content: String)
  case htmlBlock(content: String)
}

/// Information about a fenced code block
public struct FencedCodeBlockInfo: Sendable, Equatable {
  /// The fence character ('`' or '~')
  public let character: Character

  /// Length of the opening fence
  public let length: Int

  /// Programming language
  public let language: String?

  /// Full info string
  public let infoString: String
}

// MARK: - String Extensions

extension String {
  /// Leading whitespace characters
  var leadingWhitespace: CharacterSet {
    return .whitespacesAndNewlines
  }
}
