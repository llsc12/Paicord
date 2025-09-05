extension String {
    func indented() -> String {
        self.split(
            separator: "\n",
            omittingEmptySubsequences: false
        ).map {
            "    \($0)"
        }.joined(separator: "\n")
    }
}

extension [String] {
    func indented() -> String {
        self.map {
            $0.indented()
        }.joined(separator: "\n")
    }
}
