import SwiftUI
import Testing

@testable import Textual

struct InlineStyleTests {
  @Test func equality() {
    #expect(InlineStyle() == InlineStyle())
    #expect(
      InlineStyle().code(.monospaced, .fontScale(0.8))
        == InlineStyle().code(.monospaced, .fontScale(0.8))
    )
    #expect(
      InlineStyle().code(.monospaced, .fontScale(0.8))
        != InlineStyle().code(.monospaced, .fontScale(1.2))
    )
  }

  @Test func hashability() {
    #expect(InlineStyle().hashValue == InlineStyle().hashValue)
    #expect(
      InlineStyle().emphasis(.italic, .underlineStyle(.single)).hashValue
        == InlineStyle().emphasis(.italic, .underlineStyle(.single)).hashValue
    )
    #expect(InlineStyle().hashValue != InlineStyle().code(.monospaced, .fontScale(0.8)).hashValue)
  }
}
