/// A combinator that pops the first element of a stream if it satisfies a predicate.
public struct PopFirst<Context: Collection>: Combinator
where Context == Context.SubSequence
{

  public typealias Element = Context.Element

  /// The predicate that popped elements satisfy.
  public let predicate: (Context.Element) -> Bool

  /// Creates a combinator that pops the first element of stream if it satisfies `predicate`.
  public init(if predicate: @escaping (Context.Element) -> Bool) {
    self.predicate = predicate
  }

  public func parse(_ context: inout Context) throws -> Context.Element? {
    if let first = context.first, predicate(first) {
      context.removeFirst()
      return first
    } else {
      return nil
    }
  }

}
