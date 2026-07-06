import Foundation
import SwiftUI
import Testing

@testable import Textual

struct HTMLFormatterTests {
  @Test func simpleParagraph() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(markdown: "This is a simple paragraph.")
    )

    // when
    let result = formatter.html()

    // then
    #expect(result == "<p>This is a simple paragraph.</p>")
  }

  @Test func multipleParagraphs() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          First paragraph.

          Second paragraph.

          Third paragraph.
          """
      )
    )
    let expected = """
      <p>First paragraph.</p>
      <p>Second paragraph.</p>
      <p>Third paragraph.</p>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  @Test func headings() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          # Heading 1

          ## Heading 2

          ### Heading 3
          """
      )
    )
    let expected = """
      <h1>Heading 1</h1>
      <h2>Heading 2</h2>
      <h3>Heading 3</h3>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  @Test func unorderedList() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          * First item
          * Second item
          * Third item
          """
      )
    )
    let expected = """
      <ul>
      <li>First item</li>
      <li>Second item</li>
      <li>Third item</li>
      </ul>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  @Test func orderedList() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          1. First item
          2. Second item
          3. Third item
          """
      )
    )
    let expected = """
      <ol>
      <li>First item</li>
      <li>Second item</li>
      <li>Third item</li>
      </ol>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  @Test func nestedUnorderedList() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          - First item
            - Nested item 1
            - Nested item 2
          - Second item
          """
      )
    )
    let expected = """
      <ul>
      <li>First item<ul>
      <li>Nested item 1</li>
      <li>Nested item 2</li>
      </ul></li>
      <li>Second item</li>
      </ul>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  @Test func nestedOrderedList() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          1. First item
             1. Nested item 1
             2. Nested item 2
          2. Second item
          """
      )
    )
    let expected = """
      <ol>
      <li>First item<ol>
      <li>Nested item 1</li>
      <li>Nested item 2</li>
      </ol></li>
      <li>Second item</li>
      </ol>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  @Test func mixedNestedList() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          1. Ordered first
             - Unordered nested
             - Another unordered
          2. Ordered second
          """
      )
    )
    let expected = """
      <ol>
      <li>Ordered first<ul>
      <li>Unordered nested</li>
      <li>Another unordered</li>
      </ul></li>
      <li>Ordered second</li>
      </ol>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  @Test func simpleBlockQuote() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          > This is a quote.
          """
      )
    )

    // when
    let result = formatter.html()

    // then
    #expect(result == "<blockquote>\n<p>This is a quote.</p>\n</blockquote>")
  }

  @Test func blockQuoteWithParagraphs() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          Before quote.

          > This is a quote.

          After quote.
          """
      )
    )
    let expected = """
      <p>Before quote.</p>
      <blockquote>
      <p>This is a quote.</p>
      </blockquote>
      <p>After quote.</p>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  // MARK: - Code Blocks

  @Test func codeBlock() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          ```swift
          func hello() {
              print("Hello")
          }
          ```
          """
      )
    )
    let expected = """
      <pre><code class="language-swift">func hello() {
          print("Hello")
      }
      </code></pre>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  @Test func codeBlockWithoutLanguage() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          ```
          code line 1
          code line 2
          ```
          """
      )
    )

    // when
    let result = formatter.html()

    // then
    #expect(result == "<pre><code>code line 1\ncode line 2\n</code></pre>")
  }

  @Test func codeBlockWithSurroundingText() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          Before code.

          ```
          code line 1
          code line 2
          ```

          After code.
          """
      )
    )
    let expected = """
      <p>Before code.</p>
      <pre><code>code line 1
      code line 2
      </code></pre>
      <p>After code.</p>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  // MARK: - Inline Formatting

  @Test func inlineBold() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(markdown: "This is **bold** text.")
    )

    // when
    let result = formatter.html()

    // then
    #expect(result == "<p>This is <strong>bold</strong> text.</p>")
  }

  @Test func inlineItalic() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(markdown: "This is *italic* text.")
    )

    // when
    let result = formatter.html()

    // then
    #expect(result == "<p>This is <em>italic</em> text.</p>")
  }

  @Test func inlineCode() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(markdown: "This is `code` text.")
    )

    // when
    let result = formatter.html()

    // then
    #expect(result == "<p>This is <code>code</code> text.</p>")
  }

  @Test func inlineStrikethrough() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(markdown: "This is ~~strikethrough~~ text.")
    )

    // when
    let result = formatter.html()

    // then
    #expect(result == "<p>This is <del>strikethrough</del> text.</p>")
  }

  @Test func inlineLink() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(markdown: "Visit [example](https://example.com) site.")
    )

    // when
    let result = formatter.html()

    // then
    #expect(
      result
        == "<p>Visit <a href=\"https://example.com\">example</a> site.</p>"
    )
  }

  @Test func inlineBoldAndItalic() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(markdown: "This is ***bold and italic*** text.")
    )

    // when
    let result = formatter.html()

    // then
    #expect(result == "<p>This is <em><strong>bold and italic</strong></em> text.</p>")
  }

  @Test func mixedInlineFormatting() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: "This has **bold**, *italic*, `code`, and ~~strikethrough~~."
      )
    )
    let expected =
      "<p>This has <strong>bold</strong>, <em>italic</em>, <code>code</code>, and <del>strikethrough</del>.</p>"

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  // MARK: - Tables

  @Test func simpleTable() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          | Header 1 | Header 2 |
          | --- | --- |
          | Cell A1 | Cell A2 |
          | Cell B1 | Cell B2 |
          """
      )
    )
    let expected = """
      <table>
      <thead>
      <tr>
      <th align="left">Header 1</th>
      <th align="left">Header 2</th>
      </tr>
      </thead>
      <tr>
      <td align="left">Cell A1</td>
      <td align="left">Cell A2</td>
      </tr>
      <tr>
      <td align="left">Cell B1</td>
      <td align="left">Cell B2</td>
      </tr>
      </table>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  @Test func tableWithAlignment() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          | Left | Center | Right |
          | :--- | :---: | ---: |
          | A | B | C |
          """
      )
    )
    let expected = """
      <table>
      <thead>
      <tr>
      <th align="left">Left</th>
      <th align="center">Center</th>
      <th align="right">Right</th>
      </tr>
      </thead>
      <tr>
      <td align="left">A</td>
      <td align="center">B</td>
      <td align="right">C</td>
      </tr>
      </table>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  // MARK: - HTML Escaping

  @Test func htmlEscaping() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: "Text with <tags> & \"quotes\" and 'apostrophes'."
      )
    )
    let expected = "<p>Text with &lt;tags&gt; &amp; \"quotes\" and 'apostrophes'.</p>"

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  @Test func smartQuotesEscaping() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: "Hello \u{201C}world\u{201D} with \u{2018}smart\u{2019} quotes"
      )
    )
    let expected = "<p>Hello &#8220;world&#8221; with &#8216;smart&#8217; quotes</p>"

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  @Test func linkWithSpecialCharacters() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: "[link](https://example.com?foo=\"bar\"&baz=1)"
      )
    )
    let expected = "<p><a href=\"https://example.com?foo=%22bar%22&amp;baz=1\">link</a></p>"

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  // MARK: - Complex Mixed Content

  @Test func complexMixedContent() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          # Main Title

          Introduction paragraph.

          ## Section 1

          - First point
          - Second point
            - Nested point

          ## Section 2

          Some text before code.

          ```swift
          let x = 42
          ```

          ## Conclusion

          Final paragraph.
          """
      )
    )
    let expected = """
      <h1>Main Title</h1>
      <p>Introduction paragraph.</p>
      <h2>Section 1</h2>
      <ul>
      <li>First point</li>
      <li>Second point<ul>
      <li>Nested point</li>
      </ul></li>
      </ul>
      <h2>Section 2</h2>
      <p>Some text before code.</p>
      <pre><code class="language-swift">let x = 42
      </code></pre>
      <h2>Conclusion</h2>
      <p>Final paragraph.</p>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  @Test func listAfterParagraph() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          Here is a paragraph.

          - Item 1
          - Item 2
          """
      )
    )
    let expected = """
      <p>Here is a paragraph.</p>
      <ul>
      <li>Item 1</li>
      <li>Item 2</li>
      </ul>
      """

    // when
    let result = formatter.html()

    // then
    #expect(result == expected)
  }

  @Test func thematicBreak() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          First section.

          ---

          Second section.
          """
      )
    )

    // when
    let result = formatter.html()

    // then
    #expect(result == "<p>First section.</p>\n<hr />\n<p>Second section.</p>")
  }

  @Test func emptyString() throws {
    // given
    let formatter = Formatter(NSAttributedString())

    // when
    let result = formatter.html()

    // then
    #expect(result == "<p></p>")
  }
}
