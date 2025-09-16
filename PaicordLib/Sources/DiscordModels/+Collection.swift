extension Collection {
    var isNotEmpty: Bool {
        !self.isEmpty
    }
}

extension Optional where Wrapped: Collection {
    var isNotEmpty: Bool {
        self?.isNotEmpty == true
    }
}
