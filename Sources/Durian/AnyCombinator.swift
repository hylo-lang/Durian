/// A type-erased parser combinator.
public struct AnyCombinator<Context, Element>: Combinator {

  private var _parse: (inout Context) throws -> Element?

  /// Creates a type-erased combinator that forwards operations to `base`.
  public init<C: Combinator>(_ base: C) where C.Context == Context, C.Element == Element {
    self._parse = base.parse(_:)
  }

  /// Creates a type-erased combinator that forwards operations to `parse`.
  public init(parse: @escaping (inout Context) throws -> Element?) {
    self._parse = parse
  }

  public func parse(_ context: inout Context) throws -> Element? {
    try _parse(&context)
  }

}
