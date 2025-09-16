extension StringProtocol {
    func toCamelCase() -> String {
        var capitalized = self.capitalized
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: " ", with: "")
        if !capitalized.isEmpty {
            let lower = capitalized.removeFirst().lowercased()
            capitalized = lower + capitalized
        }
        return capitalized
    }

    /// Indents 4 spaces.
    func indent() -> String {
        self.components(separatedBy: .newlines).map {
            "    \($0)"
        }.joined(separator: "\n")
    }
}
