import SwiftSyntaxMacros

extension AbstractSourceLocation {
    var description: String {
        let file = self.file.description.filter({ ![" ", #"""#].contains($0) })
        return "\(file):\(self.line.description)"
    }
}
