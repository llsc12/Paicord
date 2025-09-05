import SwiftDiagnostics

enum FixMessage: String, FixItMessage {
    case useCommentsInstead

    var message: String {
        self.rawValue
    }

    var fixItID: MessageID {
        .init(domain: "UnstableEnumMacro.FixMessage", id: self.rawValue)
    }
}
