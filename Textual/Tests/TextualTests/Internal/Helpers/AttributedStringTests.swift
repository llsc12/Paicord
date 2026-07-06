import SwiftUI
import Testing

@testable import Textual

struct AttributedStringTests {
  @Test func slugified() {
    #expect(AttributedString("Hello World").slugified() == "hello-world")
    #expect(AttributedString("What's this?").slugified() == "whats-this")
    #expect(AttributedString("Hello  World").slugified() == "hello-world")
    #expect(AttributedString("A - B - C").slugified() == "a-b-c")
    #expect(AttributedString("Hello\tWorld").slugified() == "hello-world")
    #expect(AttributedString("Hello\nWorld").slugified() == "hello-world")
    #expect(AttributedString("---Hello---").slugified() == "hello")
    #expect(AttributedString("123 Test").slugified() == "123-test")
    #expect(AttributedString("").slugified() == "")
  }
}
