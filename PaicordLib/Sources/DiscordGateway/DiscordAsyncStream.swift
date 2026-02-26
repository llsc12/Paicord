/// DiscordBM's async sequence.
public struct DiscordAsyncSequence<Element: Sendable>: Sendable, AsyncSequence {

  /// DiscordBM's async sequence iterator.
  public struct AsyncIterator: AsyncIteratorProtocol {
    package var base: AsyncStream<Element>.AsyncIterator

    /// Get the next element.
    public mutating func next() async -> Element? {
      await base.next()
    }
  }

  package let base: AsyncStream<Element>

  /// Make an async iterator.
  public func makeAsyncIterator() -> AsyncIterator {
    AsyncIterator(base: base.makeAsyncIterator())
  }
  
  package init(base: AsyncStream<Element>) {
    self.base = base
  }
}
