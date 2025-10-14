/// Tokenizer for breaking markdown text into structured tokens
///
/// This tokenizer performs lexical analysis on markdown text, converting
/// it into a stream of tokens that can be consumed by the parser.
import Foundation

// MARK: - Token Types

/// Represents a single token in the markdown text
public struct Token: Sendable, Equatable {
  /// The type of the token
  public let type: TokenType

  /// The raw content of the token
  public let content: String

  /// Source location of the token
  public let location: SourceLocation

  /// Length of the token in characters
  public let length: Int

  public init(type: TokenType, content: String, location: SourceLocation) {
    self.type = type
    self.content = content
    self.location = location
    self.length = content.count
  }
}

/// Types of tokens that can be found in markdown
public enum TokenType: String, CaseIterable, Sendable, Equatable {
  // Text content
  case text
  case whitespace
  case newline

  // Headers
  case atxHeaderStart  // # ## ### etc.
  case setextHeaderUnderline  // === or ---

  // italic and strong
  case asterisk  // *
  case underscore  // _

  // Links and images
  case leftBracket  // [
  case rightBracket  // ]
  case leftParen  // (
  case rightParen  // )
  case exclamation  // !

  // Code
  case backtick  // `
  case tildeCodeFence  // ~
  case indentedCodeBlock  // 4+ spaces at line start

  // Lists
  case listMarker  // - + * or 1. 2) etc.

  // Block quotes
  case blockQuoteMarker  // >
  case multilineBlockQuoteMarker  // >>>

  // Tables (GFM)
  case pipe  // |

  // Discord spoiler syntax
  case doublePipe  // ||

  // Strikethrough (GFM)
  case tilde  // ~

  // Task lists (GFM)
  case taskListMarker  // [x] [ ]

  // URLs and emails (GFM)
  case autolink  // http://... or email@...

  // Discord-specific tokens
  case userMention  // <@123456789>
  case roleMention  // <@&123456789>
  case channelMention  // <#123456789>
  case everyoneMention  // @everyone
  case hereMention  // @here
  case timestamp  // <t:1757847540:R>
  case customEmoji  // <:name:123456789> or <a:name:123456789>

  // Escapes
  case backslash  // \
  case entity  // &amp; &#39; etc.

  // Line endings
  case hardBreak  // two spaces + newline
  case softBreak  // single newline

  // Special
  case eof  // End of file
  case footnoteHeaderMarker  // Discord '-#' footnote header
}

// MARK: - Tokenizer

/// Lexical analyzer for markdown text
public final class MarkdownTokenizer {

  private let input: String
  private let characters: [Character]
  private var position: Int = 0
  private var line: Int = 1
  private var column: Int = 1

  // State tracking for fenced code blocks
  private var inFencedCodeBlock: Bool = false
  private var fenceCharacter: Character? = nil
  private var fenceLength: Int = 0
  private var fenceStartColumn: Int = 0

  /// Initialize tokenizer with markdown text
  public init(_ input: String) {
    self.input = input
    self.characters = Array(input)
  }

  /// Tokenize the entire input into a sequence of tokens
  public func tokenize() -> [Token] {
    var tokens: [Token] = []
    while !isAtEnd {
      if let token = nextToken() {
        tokens.append(token)
        
        // hacky check for blockquote after newline, sorry.
        if token.type == .newline && !isAtEnd {
          if currentChar == ">" {
            tokens.append(tokenizeBlockQuote())
            if !isAtEnd && currentChar.isWhitespace {
              tokens.append(tokenizeWhitespace())
            }
          }
        }
      }
    }

    // Add EOF token
    tokens.append(
      Token(
        type: .eof,
        content: "",
        location: currentLocation
      )
    )

    return tokens
  }

  /// Get the next token from the input
  private func nextToken() -> Token? {
    // Skip to next meaningful character
    let startLocation = currentLocation

    guard !isAtEnd else { return nil }

    let char = currentChar

    // Check for fenced code block state BEFORE handling newlines
    if inFencedCodeBlock {
      // If we're at a newline, check if it's immediately followed by a closing fence
      if char == "\n" || char == "\r" {
        // Look ahead to see if this newline is directly before a closing fence
        let savedPosition = position
        let savedLine = line
        let savedColumn = column

        // Temporarily consume the newline
        if char == "\n" {
          advance()
        } else if char == "\r" {
          advance()
          if !isAtEnd && currentChar == "\n" {
            advance()
          }
        }

        // Skip up to 3 spaces of indentation
        var spacesSkipped = 0
        while spacesSkipped < 3 && !isAtEnd
          && (currentChar == " " || currentChar == "\t")
        {
          advance()
          spacesSkipped += 1
        }

        // Check if we have a closing fence
        if !isAtEnd && currentChar == fenceCharacter {
          var fenceCount = 0
          let fenceStart = position

          // Count fence characters
          while !isAtEnd && currentChar == fenceCharacter {
            fenceCount += 1
            advance()
          }

          // Check if this is a valid closing fence (same length or longer)
          if fenceCount >= fenceLength {
            // Verify it's followed by end of line or whitespace only
            var isValidClosingFence = true
            while !isAtEnd && currentChar != "\n" && currentChar != "\r" {
              if !currentChar.isWhitespace {
                isValidClosingFence = false
                break
              }
              advance()
            }

            if isValidClosingFence {
              // This newline is directly before a valid closing fence
              // Don't include the newline, just process the closing fence
              position = fenceStart
              line = savedLine
              column = savedColumn

              // Recalculate position to fence start
              for i in savedPosition..<fenceStart {
                if characters[i] == "\n" {
                  line += 1
                  column = 1
                } else {
                  column += 1
                }
              }

              // Process the closing fence
              let closingFence = checkClosingFenceAllowingIndentation()
              if closingFence != nil {
                inFencedCodeBlock = false
                fenceCharacter = nil
                fenceLength = 0
                fenceStartColumn = 0
              }
              return closingFence
            }
          }
        }

        // Not followed by a closing fence, restore position and process newline normally
        position = savedPosition
        line = savedLine
        column = savedColumn

        advance()
        if char == "\r" && !isAtEnd && currentChar == "\n" {
          advance()
        }
        return Token(
          type: .newline,
          content: char == "\r" ? "\r\n" : "\n",
          location: startLocation
        )
      }

      // Check for closing fence at current position
      if let closingFence = checkClosingFenceAllowingIndentation() {
        inFencedCodeBlock = false
        fenceCharacter = nil
        fenceLength = 0
        fenceStartColumn = 0
        return closingFence
      }

      // Otherwise, treat everything as text inside the code block
      return tokenizeTextInCodeBlock()
    }

    // Handle newlines (only when not in fenced code block)
    if char == "\n" {
      advance()
      return Token(type: .newline, content: "\n", location: startLocation)
    }

    if char == "\r" {
      advance()
      if currentChar == "\n" {
        advance()
      }
      return Token(type: .newline, content: "\r\n", location: startLocation)
    }
    // Check for line-start patterns (headers, lists, block quotes, etc.)
    if column == 1 || isAfterWhitespace() {
      if let lineStartToken = checkLineStartPatterns() {
        return lineStartToken
      }
    }

    // Handle whitespace
    if char.isWhitespace && char != "\n" && char != "\r" {
      return tokenizeWhitespace()
    }

    // Handle special characters
    switch char {
    case "*":
      return tokenizeAsterisk()
    case "_":
      return tokenizeUnderscore()
    case "#":
      return tokenizeHash()
    case "`":
      return tokenizeBacktick()
    case "~":
      return tokenizeTilde()
    case "[":
      return tokenizeLeftBracket()
    case "]":
      return tokenizeRightBracket()
    case "(":
      advance()
      return Token(type: .leftParen, content: "(", location: startLocation)
    case ")":
      advance()
      return Token(type: .rightParen, content: ")", location: startLocation)
    case "!":
      return tokenizeExclamation()
    case ">":
      // Discord does not support nested blockquotes. Only treat '>' as a block quote
      // marker at the true start of a line (or after leading whitespace on a new line).
      if isAtLineStart() {
        return tokenizeBlockQuote()
      } else {
        return tokenizeText()
      }
    case "|":
      return tokenizePipeOrSpoiler()
    case "\\":
      return tokenizeBackslash()
    case "&":
      return tokenizeEntity()
    case "<":
      return tokenizeDiscordEntityOrAutolink()
    case "@":
      return tokenizeAtMention()
    case "-":
      return tokenizeDashOrList()
    case "+":
      return tokenizePlusOrList()
    default:
      // Check for numbered list
      if char.isNumber {
        if let listToken = tokenizeNumberedList() {
          return listToken
        }
      }

      // Default to text
      return tokenizeText()
    }
  }

  // MARK: - Character Navigation

  private var currentChar: Character {
    guard position < characters.count else { return "\0" }
    return characters[position]
  }

  private func peek(_ offset: Int = 1) -> Character {
    let pos = position + offset
    guard pos < characters.count else { return "\0" }
    return characters[pos]
  }

  private var isAtEnd: Bool {
    return position >= characters.count
  }

  private func advance() {
    guard position < characters.count else { return }

    if characters[position] == "\n" {
      line += 1
      column = 1
    } else {
      column += 1
    }

    position += 1
  }

  private var currentLocation: SourceLocation {
    return SourceLocation(line: line, column: column, offset: position)
  }

  private func isAfterWhitespace() -> Bool {
    guard position > 0 else { return true }
    let prevChar = characters[position - 1]
    return prevChar.isWhitespace
  }

  // MARK: - Token Recognition Methods

  private func checkLineStartPatterns() -> Token? {

    // Discord footnote header: -#
    if currentChar == "-" && peek() == "#" {
      let startLocation = currentLocation
      advance()  // "-"
      advance()  // "#"
      // Must be followed by whitespace or end of line
      if isAtEnd || currentChar.isWhitespace {
        return Token(
          type: .footnoteHeaderMarker,
          content: "-#",
          location: startLocation
        )
      } else {
        // Not a valid footnote header, backtrack and treat as text
        position = startLocation.offset
        line = startLocation.line
        column = startLocation.column
      }
    }

    // Check for ATX headers (# ## ###)
    if currentChar == "#" {
      return tokenizeATXHeader()
    }

    // Check for block quotes (>)
    if currentChar == ">" {
      // Only treat '>' as a block quote marker at the true start of a line
      if isAtLineStart() {
        return tokenizeBlockQuote()
      }
    }

    // Check for list markers (- + * or 1. 2))
    if currentChar == "-" || currentChar == "+" || currentChar == "*" {
      if let listToken = tokenizeListMarker() {
        return listToken
      }
    }

    // Check for numbered lists
    if currentChar.isNumber {
      if let listToken = tokenizeNumberedList() {
        return listToken
      }
    }

    // Check for indented code blocks (4+ spaces)
    if currentChar == " " {
      if let codeBlock = tokenizeIndentedCodeBlock() {
        return codeBlock
      }
    }

    // Check for fenced code blocks (``` or ~~~)
    if currentChar == "`" || currentChar == "~" {
      if let fenceToken = tokenizeFencedCodeBlock() {
        return fenceToken
      }
    }

    return nil
  }

  private func tokenizeWhitespace() -> Token {
    let startLocation = currentLocation
    var content = ""

    while !isAtEnd && currentChar.isWhitespace && currentChar != "\n"
      && currentChar != "\r"
    {
      content.append(currentChar)
      advance()
    }

    return Token(type: .whitespace, content: content, location: startLocation)
  }

  private func tokenizeText() -> Token {
    let startLocation = currentLocation
    var content = ""

    while !isAtEnd && !isSpecialCharacter(currentChar) && currentChar != "\n"
      && currentChar != "\r"
    {
      content.append(currentChar)
      advance()
    }

    // If we didn't consume any characters, consume at least one to avoid infinite loop
    if content.isEmpty && !isAtEnd {
      content.append(currentChar)
      advance()
    }

    return Token(type: .text, content: content, location: startLocation)
  }

  private func isSpecialCharacter(_ char: Character) -> Bool {
    return "*_#`~[]()!>|\\&<-+@".contains(char) || char.isWhitespace
  }

  private func tokenizeAsterisk() -> Token {
    let startLocation = currentLocation
    advance()
    return Token(type: .asterisk, content: "*", location: startLocation)
  }

  private func tokenizeUnderscore() -> Token {
    let startLocation = currentLocation
    advance()
    return Token(type: .underscore, content: "_", location: startLocation)
  }

  private func tokenizeHash() -> Token {
    let startLocation = currentLocation
    advance()
    return Token(type: .atxHeaderStart, content: "#", location: startLocation)
  }

  private func tokenizeATXHeader() -> Token {
    let startLocation = currentLocation
    var content = ""

    while !isAtEnd && currentChar == "#" && content.count < 6 {
      content.append(currentChar)
      advance()
    }

    // Must be followed by space or end of line
    if !isAtEnd && !currentChar.isWhitespace {
      // Not a header, backtrack and return as text
      position = startLocation.offset
      line = startLocation.line
      column = startLocation.column
      return tokenizeText()
    }

    return Token(
      type: .atxHeaderStart,
      content: content,
      location: startLocation
    )
  }

  private func tokenizeBacktick() -> Token {
    let startLocation = currentLocation
    var content = ""

    while !isAtEnd && currentChar == "`" {
      content.append(currentChar)
      advance()
    }

    return Token(type: .backtick, content: content, location: startLocation)
  }

  private func tokenizeTilde() -> Token {
    let startLocation = currentLocation
    var content = ""

    while !isAtEnd && currentChar == "~" {
      content.append(currentChar)
      advance()
    }

    return Token(type: .tilde, content: content, location: startLocation)
  }

  private func tokenizeLeftBracket() -> Token {
    let startLocation = currentLocation

    // Check if this could be a task list marker
    if let taskListToken = tokenizeTaskListMarker() {
      return taskListToken
    }

    // Default to regular left bracket
    advance()
    return Token(type: .leftBracket, content: "[", location: startLocation)
  }

  /// Tokenize task list markers like [x], [ ], [X], etc.
  private func tokenizeTaskListMarker() -> Token? {
    let startLocation = currentLocation

    // Must start with [
    guard currentChar == "[" else { return nil }

    // Look ahead to see if this forms a valid task list marker
    guard position + 2 < characters.count else { return nil }

    let nextChar = characters[position + 1]
    let closingChar = characters[position + 2]

    // Must end with ]
    guard closingChar == "]" else { return nil }

    // Check if the middle character is valid for task list
    let validTaskChars: Set<Character> = ["x", "X", " ", "o", "O", "v", "V"]
    guard validTaskChars.contains(nextChar) else { return nil }

    // Additional validation: must be in a list context
    // Check if we're after a list marker and whitespace
    if !isInTaskListContext() {
      return nil
    }

    // Check if there's a space after the ] (required by GFM spec)
    if position + 3 < characters.count {
      let charAfterBracket = characters[position + 3]
      if !charAfterBracket.isWhitespace {
        return nil
      }
    }

    // Valid task list marker - consume all three characters
    let content = String(characters[position...position + 2])
    advance()  // [
    advance()  // x or space or other valid char
    advance()  // ]

    return Token(
      type: .taskListMarker,
      content: content,
      location: startLocation
    )
  }

  /// Check if we're in a context where task list markers are valid
  private func isInTaskListContext() -> Bool {
    // Look backwards to see if we're after a list marker and whitespace
    var pos = position - 1

    // Must have at least one space before the [
    guard pos >= 0 && characters[pos] == " " else { return false }

    // Skip whitespace backwards (but we need at least one space)
    while pos >= 0 && characters[pos].isWhitespace && characters[pos] != "\n"
      && characters[pos] != "\r"
    {
      pos -= 1
    }

    // Should find a list marker
    guard pos >= 0 else { return false }

    let char = characters[pos]

    // Check for bullet list markers
    if char == "-" || char == "+" || char == "*" {
      // Must be at start of line or after whitespace
      if pos == 0 || characters[pos - 1].isWhitespace {
        return true
      }
    }

    // Check for numbered list markers (look for . or ))
    if char == "." || char == ")" {
      // Look backwards for digits
      var digitPos = pos - 1
      var hasDigits = false

      while digitPos >= 0 && characters[digitPos].isNumber {
        hasDigits = true
        digitPos -= 1
      }

      // Must have digits and be at start of line or after whitespace
      if hasDigits && (digitPos < 0 || characters[digitPos].isWhitespace) {
        return true
      }
    }

    return false
  }

  private func tokenizeRightBracket() -> Token {
    let startLocation = currentLocation
    advance()
    return Token(type: .rightBracket, content: "]", location: startLocation)
  }

  private func tokenizeExclamation() -> Token {
    let startLocation = currentLocation
    advance()
    return Token(type: .exclamation, content: "!", location: startLocation)
  }

  private func tokenizeBlockQuote() -> Token {
    let startLocation = currentLocation

    // Check if this is a multiline block quote (>>>)
    if peek() == ">" && peek(2) == ">" {
      advance()  // First >
      advance()  // Second >
      advance()  // Third >
      return Token(
        type: .multilineBlockQuoteMarker,
        content: ">>>",
        location: startLocation
      )
    }

    // Single block quote
    advance()
    return Token(type: .blockQuoteMarker, content: ">", location: startLocation)
  }

  private func tokenizeBackslash() -> Token {
    let startLocation = currentLocation
    var content = ""
    content.append(currentChar)
    advance()

    // Include the escaped character if present
    if !isAtEnd {
      content.append(currentChar)
      advance()
    }

    return Token(type: .backslash, content: content, location: startLocation)
  }

  private func tokenizeEntity() -> Token {
    let startLocation = currentLocation
    var content = ""

    content.append(currentChar)  // &
    advance()

    // Read until ; or whitespace
    while !isAtEnd && currentChar != ";" && !currentChar.isWhitespace {
      content.append(currentChar)
      advance()
    }

    if currentChar == ";" {
      content.append(currentChar)
      advance()
    }

    return Token(type: .entity, content: content, location: startLocation)
  }

  private func tokenizeDiscordEntityOrAutolink() -> Token {
    // Check if this looks like a Discord entity
    if isDiscordEntity() {
      return tokenizeDiscordEntity()
    }

    // Check if this looks like an autolink
    if isAutolink() {
      return tokenizeAutolink()
    }

    // Default to text
    return tokenizeText()
  }

  private func isDiscordEntity() -> Bool {
    guard currentChar == "<" else { return false }

    var pos = position + 1
    guard pos < characters.count else { return false }

    let nextChar = characters[pos]

    // Check for Discord entity patterns:
    // <@123> - user mention
    // <@&123> - role mention
    // <#123> - channel mention
    // <t:123:R> - timestamp
    // <:name:123> or <a:name:123> - custom emoji

    // User mention: <@123>
    if nextChar == "@" {
      pos += 1
      // Skip optional & for role mentions
      if pos < characters.count && characters[pos] == "&" {
        pos += 1
      }
      // Must have digits
      if pos < characters.count && characters[pos].isNumber {
        while pos < characters.count && characters[pos].isNumber {
          pos += 1
        }
        return pos < characters.count && characters[pos] == ">"
      }
    }

    // Channel mention: <#123>
    if nextChar == "#" {
      pos += 1
      // Must have digits
      if pos < characters.count && characters[pos].isNumber {
        while pos < characters.count && characters[pos].isNumber {
          pos += 1
        }
        return pos < characters.count && characters[pos] == ">"
      }
    }

    // Timestamp: <t:123:R>
    if nextChar == "t" && pos + 1 < characters.count
      && characters[pos + 1] == ":"
    {
      pos += 2
      // Must have digits
      if pos < characters.count && characters[pos].isNumber {
        while pos < characters.count && characters[pos].isNumber {
          pos += 1
        }
        // Must have : and style character
        if pos + 1 < characters.count && characters[pos] == ":" {
          pos += 2  // Skip : and style char
          return pos < characters.count && characters[pos] == ">"
        }
      }
    }

    // Custom emoji: <:name:123> or <a:name:123>
    if nextChar == ":"
      || (nextChar == "a" && pos + 1 < characters.count
        && characters[pos + 1] == ":")
    {
      if nextChar == "a" {
        pos += 2  // Skip "a:"
      } else {
        pos += 1  // Skip ":"
      }
      // Must have name
      if pos < characters.count
        && (characters[pos].isLetter || characters[pos] == "_")
      {
        while pos < characters.count
          && (characters[pos].isLetter || characters[pos].isNumber
            || characters[pos] == "_")
        {
          pos += 1
        }
        // Must have : and digits
        if pos < characters.count && characters[pos] == ":" {
          pos += 1
          if pos < characters.count && characters[pos].isNumber {
            while pos < characters.count && characters[pos].isNumber {
              pos += 1
            }
            return pos < characters.count && characters[pos] == ">"
          }
        }
      }
    }

    return false
  }

  private func tokenizeDiscordEntity() -> Token {
    let startLocation = currentLocation
    var content = ""

    content.append(currentChar)  // <
    advance()

    let nextChar = currentChar

    // User mention: <@123> or <@&123>
    if nextChar == "@" {
      content.append(currentChar)
      advance()

      // Check for role mention marker
      let isRole = currentChar == "&"
      if isRole {
        content.append(currentChar)
        advance()
      }

      // Read digits
      while !isAtEnd && currentChar.isNumber {
        content.append(currentChar)
        advance()
      }

      // Must end with >
      if currentChar == ">" {
        content.append(currentChar)
        advance()

        let tokenType: TokenType = isRole ? .roleMention : .userMention
        return Token(type: tokenType, content: content, location: startLocation)
      }
    }

    // Channel mention: <#123>
    else if nextChar == "#" {
      content.append(currentChar)
      advance()

      // Read digits
      while !isAtEnd && currentChar.isNumber {
        content.append(currentChar)
        advance()
      }

      // Must end with >
      if currentChar == ">" {
        content.append(currentChar)
        advance()

        return Token(
          type: .channelMention,
          content: content,
          location: startLocation
        )
      }
    }

    // Timestamp: <t:123:R>
    else if nextChar == "t" && peek() == ":" {
      content.append(currentChar)  // t
      advance()
      content.append(currentChar)  // :
      advance()

      // Read timestamp digits
      while !isAtEnd && currentChar.isNumber {
        content.append(currentChar)
        advance()
      }

      // Must have : and style
      if currentChar == ":" {
        content.append(currentChar)
        advance()

        // Read style character
        if !isAtEnd {
          content.append(currentChar)
          advance()
        }

        // Must end with >
        if currentChar == ">" {
          content.append(currentChar)
          advance()

          return Token(
            type: .timestamp,
            content: content,
            location: startLocation
          )
        }
      }
    }

    // Custom emoji: <:name:123> or <a:name:123>
    else if nextChar == ":" || (nextChar == "a" && peek() == ":") {
      let isAnimated = nextChar == "a"

      if isAnimated {
        content.append(currentChar)  // a
        advance()
      }

      content.append(currentChar)  // :
      advance()

      // Read emoji name
      while !isAtEnd
        && (currentChar.isLetter || currentChar.isNumber || currentChar == "_")
      {
        content.append(currentChar)
        advance()
      }

      // Must have : and digits
      if currentChar == ":" {
        content.append(currentChar)
        advance()

        // Read emoji ID digits
        while !isAtEnd && currentChar.isNumber {
          content.append(currentChar)
          advance()
        }

        // Must end with >
        if currentChar == ">" {
          content.append(currentChar)
          advance()

          return Token(
            type: .customEmoji,
            content: content,
            location: startLocation
          )
        }
      }
    }

    // If we get here, it's not a valid Discord entity, backtrack and return as text
    position = startLocation.offset
    line = startLocation.line
    column = startLocation.column
    return tokenizeText()
  }

  private func isAutolink() -> Bool {
    //    return remaining.hasPrefix("http://") || remaining.hasPrefix("https://")
    //          || remaining.contains("@")

    // Only match valid URLs or valid emails
    let remaining = String(characters[position...])
    if remaining.hasPrefix("http://") || remaining.hasPrefix("https://") {
      return true
    }

    // Better email check
    let emailRegex = "^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$"
    if remaining.range(of: emailRegex, options: .regularExpression) != nil {
      return true
    }
    return false
    // all of that should fix testInvalidMentionEdgeCases
  }

  private func tokenizeAutolink() -> Token {
    let startLocation = currentLocation
    var content = ""

    // Read until whitespace or special character
    while !isAtEnd && !currentChar.isWhitespace && !"[]()".contains(currentChar)
    {
      content.append(currentChar)
      advance()
    }

    return Token(type: .autolink, content: content, location: startLocation)
  }

  private func tokenizeDashOrList() -> Token {

    // Check if this is a list marker
    if let listToken = tokenizeListMarker() {
      return listToken
    }

    // Default to text
    return tokenizeText()
  }

  private func tokenizePlusOrList() -> Token {

    // Check if this is a list marker
    if let listToken = tokenizeListMarker() {
      return listToken
    }

    // Default to text
    return tokenizeText()
  }

  private func tokenizeListMarker() -> Token? {
    let startLocation = currentLocation
    let char = currentChar

    guard char == "-" || char == "+" || char == "*" else { return nil }

    advance()

    // Must be followed by whitespace
    if !isAtEnd && !currentChar.isWhitespace {
      // Not a list marker, backtrack
      position = startLocation.offset
      line = startLocation.line
      column = startLocation.column
      return nil
    }

    return Token(
      type: .listMarker,
      content: String(char),
      location: startLocation
    )
  }

  private func tokenizeNumberedList() -> Token? {
    let startLocation = currentLocation
    var content = ""

    // Only consider numbered lists if we're at the actual start of a line
    // or after specific indentation (not just any whitespace)
    if !isAtActualLineStart() {
      return nil
    }

    // Read digits
    while !isAtEnd && currentChar.isNumber && content.count < 9 {
      content.append(currentChar)
      advance()
    }

    // Must be followed by . or )
    guard !isAtEnd && (currentChar == "." || currentChar == ")") else {
      // Not a numbered list, backtrack
      position = startLocation.offset
      line = startLocation.line
      column = startLocation.column
      return nil
    }

    content.append(currentChar)
    advance()

    // Must be followed by whitespace
    if !isAtEnd && !currentChar.isWhitespace {
      // Not a list marker, backtrack
      position = startLocation.offset
      line = startLocation.line
      column = startLocation.column
      return nil
    }

    return Token(type: .listMarker, content: content, location: startLocation)
  }

  /// Check if we're at the actual start of a line (column 1) or after valid list indentation
  private func isAtActualLineStart() -> Bool {
    // If we're at column 1, this is definitely line start
    if column == 1 {
      return true
    }

    // For list markers, we need to be more careful about indentation
    // Check if all characters before this on the current line are whitespace
    // and we have a valid indentation amount (0-3 spaces for list markers)
    var spaceCount = 0
    var pos = position - 1

    while pos >= 0 && characters[pos] != "\n" && characters[pos] != "\r" {
      if characters[pos] == " " {
        spaceCount += 1
      } else if characters[pos] == "\t" {
        spaceCount += 4  // Treat tab as 4 spaces
      } else {
        // Non-whitespace character found before current position on this line
        return false
      }
      pos -= 1
    }

    // List markers can be indented by 0-3 spaces
    return spaceCount <= 3
  }

  private func tokenizeIndentedCodeBlock() -> Token? {
    let startLocation = currentLocation
    var spaceCount = 0

    // Count leading spaces
    while !isAtEnd && currentChar == " " {
      spaceCount += 1
      advance()
    }

    // Must have at least 4 spaces
    guard spaceCount >= 4 else {
      // Backtrack
      position = startLocation.offset
      line = startLocation.line
      column = startLocation.column
      return nil
    }

    return Token(
      type: .indentedCodeBlock,
      content: String(repeating: " ", count: spaceCount),
      location: startLocation
    )
  }

  private func tokenizeFencedCodeBlock() -> Token? {
    let startLocation = currentLocation
    let fenceChar = currentChar
    var content = ""

    // Count fence characters
    while !isAtEnd && currentChar == fenceChar {
      content.append(currentChar)
      advance()
    }

    // Must have at least 3 characters
    guard content.count >= 3 else {
      // Backtrack
      position = startLocation.offset
      line = startLocation.line
      column = startLocation.column
      return nil
    }

    // Set fenced code block state
    inFencedCodeBlock = true
    fenceCharacter = fenceChar
    fenceLength = content.count
    fenceStartColumn = startLocation.column

    let tokenType: TokenType = fenceChar == "`" ? .backtick : .tildeCodeFence
    return Token(type: tokenType, content: content, location: startLocation)
  }

  private func checkClosingFence() -> Token? {
    let startLocation = currentLocation
    let char = currentChar

    guard char == fenceCharacter else { return nil }

    var content = ""
    var count = 0

    // Count fence characters
    while !isAtEnd && currentChar == char {
      content.append(currentChar)
      count += 1
      advance()
    }

    // Must have at least the same length as opening fence
    guard count >= fenceLength else {
      // Backtrack - this is not a closing fence
      position = startLocation.offset
      line = startLocation.line
      column = startLocation.column
      return nil
    }

    // Check that this is followed by end of line or whitespace only
    // This ensures we don't close on fence characters that are part of content
    var tempPos = position

    while tempPos < characters.count && characters[tempPos] != "\n"
      && characters[tempPos] != "\r"
    {
      if !characters[tempPos].isWhitespace {
        // There's non-whitespace content after the fence, so this is not a closing fence
        position = startLocation.offset
        line = startLocation.line
        column = startLocation.column
        return nil
      }
      tempPos += 1
    }

    let tokenType: TokenType = char == "`" ? .backtick : .tildeCodeFence
    return Token(type: tokenType, content: content, location: startLocation)
  }

  private func tokenizeTextInCodeBlock() -> Token {
    let startLocation = currentLocation
    var content = ""

    // Consume characters until newline, but stop if we are about to hit a valid
    // closing fence on this line (to allow single-line fenced blocks like ```code```).
    while !isAtEnd && currentChar != "\n" && currentChar != "\r" {
      // If we see the fence character, check if from here to end-of-line is a valid
      // closing fence (>= opening length and followed only by whitespace).
      if let fenceChar = fenceCharacter, currentChar == fenceChar {
        // Look ahead without consuming to verify a valid closing fence sequence.
        var pos = position
        var count = 0
        while pos < characters.count && characters[pos] == fenceChar {
          count += 1
          pos += 1
        }
        if count >= fenceLength {
          // Ensure the remainder of the line is whitespace only.
          var onlyWhitespaceToEOL = true
          var scan = pos
          while scan < characters.count && characters[scan] != "\n" && characters[scan] != "\r" {
            if !characters[scan].isWhitespace {
              onlyWhitespaceToEOL = false
              break
            }
            scan += 1
          }
          if onlyWhitespaceToEOL {
            // Stop before the fence so that the outer loop can emit the fence token.
            break
          }
        }
      }

      content.append(currentChar)
      advance()
    }

    return Token(type: .text, content: content, location: startLocation)
  }

  /// Attempt to detect a closing code fence that may be indented by up to three leading spaces.
  /// This ensures that we can preserve whitespace inside code blocks while still correctly
  /// terminating the fenced block when the specification allows indentation.
  private func checkClosingFenceAllowingIndentation() -> Token? {
    // Ensure we have a fence character recorded; otherwise there is nothing to close.
    guard let fenceChar = fenceCharacter else { return nil }

    // Capture the current parser state *before* we attempt any operation that may mutate it.
    let originalPosition = position
    let originalLine = line
    let originalColumn = column

    // We allow closing fences to appear anywhere on the line (Discord-style),
    // provided that from the fence start to end-of-line there is only the fence
    // and optional trailing whitespace. We also allow up to 3 leading spaces/tabs
    // before the fence (standard indentation allowance).

    // Skip up to three leading spaces or tabs.
    var spacesSkipped = 0
    while spacesSkipped < 3 && !isAtEnd {
      if currentChar == " " || currentChar == "\t" {
        advance()
        spacesSkipped += 1
      } else {
        break
      }
    }

    // After skipping indentation, the next character must match the opening fence character.
    if currentChar == fenceChar {
      // Defer to the standard closing-fence logic which validates count and trailing content.
      if let fence = checkClosingFence() {
        return fence
      }
    }

    // Not a valid closing fence – restore parser state and signal failure.
    position = originalPosition
    line = originalLine
    column = originalColumn
    return nil
  }

  private func isAtLineStart() -> Bool {
    // Check if we're at the actual start of a line (column 1)
    // or if we're after whitespace at the start of a line
    if column == 1 {
      return true
    }

    // Check if all characters before this on the current line are whitespace
    var pos = position - 1
    while pos >= 0 && characters[pos] != "\n" && characters[pos] != "\r" {
      if !characters[pos].isWhitespace {
        return false
      }
      pos -= 1
    }
    return true
  }

  private func tokenizePipeOrSpoiler() -> Token {
    let startLocation = currentLocation

    // Check if this is a double pipe (spoiler)
    if peek() == "|" {
      advance()  // First |
      advance()  // Second |
      return Token(type: .doublePipe, content: "||", location: startLocation)
    }

    // Single pipe for tables
    advance()
    return Token(type: .pipe, content: "|", location: startLocation)
  }

  private func tokenizeAtMention() -> Token {
    let startLocation = currentLocation

    // Check for @everyone
    if String(characters[position...]).hasPrefix("@everyone") {
      var content = ""
      for _ in 0..<9 {  // "@everyone".count
        if !isAtEnd {
          content.append(currentChar)
          advance()
        }
      }
      return Token(
        type: .everyoneMention,
        content: content,
        location: startLocation
      )
    }

    // Check for @here
    if String(characters[position...]).hasPrefix("@here") {
      var content = ""
      for _ in 0..<5 {  // "@here".count
        if !isAtEnd {
          content.append(currentChar)
          advance()
        }
      }
      return Token(
        type: .hereMention,
        content: content,
        location: startLocation
      )
    }

    // Not a special mention, treat as text
    return tokenizeText()
  }
}

// MARK: - Token Stream

/// A stream of tokens that can be consumed by the parser
public final class TokenStream {
  private let tokens: [Token]
  private var position: Int = 0

  public init(_ tokens: [Token]) {
    self.tokens = tokens
  }

  /// Current token
  public var current: Token {
    guard position < tokens.count else {
      return Token(
        type: .eof,
        content: "",
        location: SourceLocation(line: 0, column: 0, offset: 0)
      )
    }
    return tokens[position]
  }

  /// Peek at the next token
  public func peek(_ offset: Int = 1) -> Token {
    let pos = position + offset
    guard pos >= 0 && pos < tokens.count else {
      return Token(
        type: .eof,
        content: "",
        location: SourceLocation(line: 0, column: 0, offset: 0)
      )
    }
    return tokens[pos]
  }

  /// Advance to the next token
  public func advance() {
    if position < tokens.count {
      position += 1
    }
  }

  /// Check if we're at the end
  public var isAtEnd: Bool {
    return position >= tokens.count || current.type == .eof
  }

  /// Consume and return the current token
  public func consume() -> Token {
    let token = current
    advance()
    return token
  }

  /// Check if current token matches the given type
  public func check(_ type: TokenType) -> Bool {
    return current.type == type
  }

  /// Consume token if it matches the given type
  public func match(_ types: TokenType...) -> Bool {
    for type in types {
      if check(type) {
        advance()
        return true
      }
    }
    return false
  }

  /// Current position in the token stream (for backtracking)
  public var currentPosition: Int {
    return position
  }

  /// Set position in the token stream (for backtracking)
  public func setPosition(_ pos: Int) {
    position = max(0, min(pos, tokens.count))
  }
}
