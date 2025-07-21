import Foundation

/// A combinator that can be used recursively.
public struct Recursive<Context, Element>: Combinator, Sendable {

  private final class Definition: @unchecked Sendable {

    var make: () -> (inout Context) throws -> Element?

    var parse: ((inout Context) throws -> Element?)?
    
    /// Lock used for thread-safe initialization of the parse property (TODO - find a better alternative)
    private let lock = NSLock()

    init(make: @escaping () -> (inout Context) throws -> Element?) {
      self.make = make
    }
    
    /// Thread-safe accessor for the parse property
    func getOrCreateParser() -> (inout Context) throws -> Element? {
      if let existingParser = parse {
        return existingParser
      }
      
      lock.lock()
      defer { lock.unlock() }
      
      if parse == nil {
        parse = make()
      }
      
      return parse!
    }

  }

  /// The definition of the combinator.
  private let definition: Definition

  /// Declares combinator that forwards operation to combinator returned by `makeParse`.
  public init(_ makeParse: @autoclosure @escaping () -> (inout Context) throws -> Element?) {
    self.definition = Definition(make: makeParse)
  }

  public func parse(_ context: inout Context) throws -> Element? {
    let parser = definition.getOrCreateParser()
    return try parser(&context)
  }

}
