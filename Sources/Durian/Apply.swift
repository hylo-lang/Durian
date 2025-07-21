/// A combinator that applies a closure.
public struct Apply<Context, Element>: Combinator {

  /// The action to apply.
  public let action: @Sendable (inout Context) throws -> Element?

  /// Creates a combinator applying the specified closure.
  public init(_ action: @Sendable @escaping (inout Context) throws -> Element?) {
    self.action = action
  }

  public func parse(_ context: inout Context) throws -> Element? {
    try action(&context)
  }

}
