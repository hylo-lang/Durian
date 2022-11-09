/// A combinator that applies a combinator and then, if successful, passes its result to a
/// function returning the next combinator to apply.
public struct Bind<Base: Combinator, Next: Combinator>: Combinator
where Base.Context == Next.Context
{

  public typealias Context = Base.Context

  public typealias Element = Next.Element

  /// The base combinator.
  public let base: Base

  /// A function that accepts the result of `base` and returns a new combinator.
  public let makeNext: (Base.Element) throws -> Next

  /// Creates a combinator that applies `base` and then the combinator returned by `makeNext`.
  public init(_ base: Base, and makeNext: @escaping (Base.Element) throws -> Next) {
    self.base = base
    self.makeNext = makeNext
  }

  public func parse(_ context: inout Context) throws -> Next.Element? {
    if let a = try base.parse(&context) {
      return try makeNext(a).parse(&context)
    } else {
      return nil
    }
  }

}
