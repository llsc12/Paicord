import SwiftUI
import Testing

@testable import Textual

extension AttributedString {
  struct BlockRunsTests {
    @Test func emptyString() throws {
      // given
      let attributedString = try AttributedString(markdown: "")

      // then
      #expect(attributedString.blockRuns().isEmpty)
    }

    @Test func singleParagraph() throws {
      // given
      let attributedString = try AttributedString(markdown: "Hello, *world*!")

      // when
      let blocks = attributedString.blockRuns()

      // then
      #expect(blocks.count == 1)
      #expect(blocks[0].intent?.kind == .paragraph)
      #expect(attributedString[blocks[0].range] == attributedString)
    }

    @Test func consecutiveParagraphs() throws {
      // given
      let attributedString = try AttributedString(
        markdown: """
          First paragraph.

          Second paragraph.
          """
      )

      // when
      let blocks = attributedString.blockRuns()

      // then
      #expect(blocks.count == 2)
      #expect(blocks[0].intent?.kind == .paragraph)
      #expect(
        String(attributedString[blocks[0].range].characters[...]) == "First paragraph."
      )
      #expect(blocks[1].intent?.kind == .paragraph)
      #expect(
        String(attributedString[blocks[1].range].characters[...]) == "Second paragraph."
      )
    }

    @Test func headingAndParagraph() throws {
      // given
      let attributedString = try AttributedString(
        markdown: """
          # Introduction to `foo`
          Hello, **world**!
          """
      )

      // when
      let blocks = attributedString.blockRuns()

      // then
      #expect(blocks.count == 2)
      #expect(blocks[0].intent?.kind == .header(level: 1))
      #expect(
        String(attributedString[blocks[0].range].characters[...]) == "Introduction to foo"
      )
      #expect(blocks[1].intent?.kind == .paragraph)
      #expect(
        String(attributedString[blocks[1].range].characters[...]) == "Hello, world!"
      )
    }

    @Test func htmlBlock() throws {
      // given
      let attributedString = try AttributedString(
        markdown: """
          <p>This is an HTML block</p>

          # Introduction to `foo`
          Hello, **world**!

          <p>This is another HTML block</p>
          """
      )

      // when
      let blocks = attributedString.blockRuns()

      // then
      #expect(blocks.count == 4)
      #expect(blocks[0].intent == nil)
      #expect(
        String(attributedString[blocks[0].range].characters[...])
          == "<p>This is an HTML block</p>\n"
      )
      #expect(blocks[3].intent == nil)
      #expect(
        String(attributedString[blocks[3].range].characters[...])
          == "<p>This is another HTML block</p>\n"
      )
    }

    @Test func nestedBlocks() throws {
      // given
      let attributedString = try AttributedString(
        markdown: """
          This is a list:
          - Item A
          - <p>Item B</p>
          - Item C
          """
      )

      // when
      let blocks = attributedString.blockRuns()
      let listBlock = blocks[1]

      // then
      #expect(blocks.count == 2)
      #expect(blocks[1].intent?.kind == .unorderedList)

      // when
      let list = attributedString[listBlock.range]
      let itemBlocks = list.blockRuns(parent: listBlock.intent)

      // then
      #expect(itemBlocks.count == 3)
      #expect(
        String(attributedString[itemBlocks[0].range].characters[...]) == "Item A"
      )

      // when
      let secondItemBlock = itemBlocks[1]
      let secondItem = list[secondItemBlock.range]
      let secondItemBlocks = secondItem.blockRuns(parent: secondItemBlock.intent)

      // then
      #expect(secondItem == attributedString[secondItemBlock.range])
      #expect(secondItemBlocks.count == 1)
      #expect(secondItemBlocks[0].intent == nil)
      #expect(
        String(secondItem[secondItemBlocks[0].range].characters[...]) == "<p>Item B</p>\n"
      )
    }

    @Test func substringRangesWorkInParent() throws {
      // given
      let attributedString = try AttributedString(
        markdown: """
          # Header
          This is a paragraph with **bold** text.
          - List item 1
          - List item 2
          """
      )

      // when
      let blocks = attributedString.blockRuns()
      let listBlock = blocks[2]
      let list = attributedString[listBlock.range]

      let itemBlocks = list.blockRuns(parent: listBlock.intent)

      // then
      for itemBlock in itemBlocks {
        let fromSubstring = list[itemBlock.range]
        let fromParent = attributedString[itemBlock.range]

        #expect(fromSubstring == fromParent)
        #expect(String(fromSubstring.characters) == String(fromParent.characters))
      }

      let firstItem = attributedString[itemBlocks[0].range]
      #expect(String(firstItem.characters[...]) == "List item 1")

      let secondItem = attributedString[itemBlocks[1].range]
      #expect(String(secondItem.characters[...]) == "List item 2")
    }
  }
}
