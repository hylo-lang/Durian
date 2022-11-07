/// A combinator that combines the result of other combinators.
public struct Combine<First: Combinator, Second: Combinator>: Combinator
where First.Context == Second.Context
{

  public typealias Context = First.Context

  public typealias Element = (First.Element, Second.Element)

  /// The first combinator.
  public let firstCombinator: First

  /// The second combinator.
  public let secondCombinator: Second

  /// A closure that produces a hard failure when `secondCombinator` returns a soft failure.
  public let makeHardFailure: (inout Context) -> Error

  /// Creates a combinator that applies `first` and then `second`.
  public init(_ first: First, and second: Second) {
    self.init(first, and: second, else: { _ in HardFailure() })
  }

  /// Creates a combinator that applies `first` and then `second`, producing hard failures with
  /// `makeHardFailure` when `second` returns a soft failure.
  public init(
    _ first: First,
    and second: Second,
    else makeHardFailure: @escaping (inout Context) -> Error
  ) {
    self.firstCombinator = first
    self.secondCombinator = second
    self.makeHardFailure = makeHardFailure
  }

  public func parse(_ context: inout Context) throws -> Element? {
    if let a = try firstCombinator.parse(&context) {
      if let b = try secondCombinator.parse(&context) {
        return (a, b)
      } else {
        throw makeHardFailure(&context)
      }
    } else {
      return nil
    }
  }

  /// Returns a combinator that discards the second result of `self`.
  public var first: Apply<First.Context, First.Element> {
    Apply({ (context) in (try parse(&context))?.0 })
  }

  /// Returns a combinator that discards the first result of `self`.
  public var second: Apply<First.Context, Second.Element> {
    Apply({ (context) in (try parse(&context))?.1 })
  }

}
