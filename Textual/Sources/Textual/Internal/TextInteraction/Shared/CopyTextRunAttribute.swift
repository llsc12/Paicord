import SwiftUI

@available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *)
struct CopyTextRunAttribute: TextAttribute {
  var text: String

  init(_ text: String) {
    self.text = text
  }
}

@available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *)
extension Text.Layout.Run {
  var copyText: String? {
    self[CopyTextRunAttribute.self]?.text
  }
}
