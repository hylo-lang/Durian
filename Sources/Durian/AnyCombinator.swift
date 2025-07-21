/// A type-erased parser combinator.

public struct AnyCombinator<Context: Sendable, Element: Sendable>: Combinator {
  private let _parse: @Sendable (inout Context) throws -> Element?

  /// Wrap any other `Combinator` with matching Context/Element.
  public init<C: Combinator>(_ base: C)
  where C.Context == Context, C.Element == Element {
    self._parse = { context in
      try base.parse(&context)
    }
  }

  /// Creates a type-erased combinator that forwards operations to `parse`.
  public init(parse: @Sendable @escaping (inout Context) throws -> Element?) {
    self._parse = parse
  }

  public func parse(_ context: inout Context) throws -> Element? {
    try _parse(&context)
  }
}
