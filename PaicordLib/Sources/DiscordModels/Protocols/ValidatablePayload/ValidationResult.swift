protocol ValidationResult {
    func get() -> [ValidationFailure]
}

extension ValidationFailure: ValidationResult {
    func get() -> [ValidationFailure] {
        [self]
    }
}

extension [ValidationFailure]: ValidationResult {
    func get() -> [ValidationFailure] {
        self
    }
}

extension Optional: ValidationResult where Wrapped: ValidationResult {
    func get() -> [ValidationFailure] {
        self?.get() ?? []
    }
}
