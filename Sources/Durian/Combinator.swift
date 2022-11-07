/// A parser combinator.
public protocol Combinator {

  /// The context from which element are being parsed, typically a stream of tokens.
  ///
  /// - Requires: `Context` must have value semantics.
  associatedtype Context

  /// The element parsed by the combinator.
  associatedtype Element

  /// Attempts to parse a result from `context`.
  func parse(_ context: inout Context) throws -> Element?

}

postfix operator +

postfix operator *

extension Combinator {

  /// Creates a combinator that applies `self` and then `other`.
  public func and<Other: Combinator>(_ other: Other) -> Combine<Self, Other> {
    Combine(self, and: other)
  }

  /// Creates a combinator that applies `self` and then `other`, producing hard failures with
  /// `makeHardFailure` when `other` returns a soft failure .
  public func and<Other: Combinator>(
    _ other: Other,
    else makeHardFailure: @escaping (inout Context) -> Error
  ) -> Combine<Self, Other> {
    Combine(self, and: other, else: makeHardFailure)
  }

  /// Creates a combinator that applies `self`, or backtracks and applies `other` when `self`
  /// return a soft failure.
  public func or<Other: Combinator>(_ other: Other) -> Choose<Self, Other> {
    Choose(self, or: other)
  }

  /// Creates a combinator that applies `self`, or backtracks and applies `other` when `self`
  /// returns any kind of failure.
  public func orCatch<Other: Combinator>(
    andApply other: Other
  ) -> TryCatch<Self, Other> {
    TryCatch(trying: self, orCatchingAndApplying: other)
  }

  /// Creates a combinators that transforms the result of `self`.
  public func map<T>(
    _ transform: @escaping (inout Context, Element) throws -> T
  ) -> Transform<Self, T> {
    Transform(base: self, transform: transform)
  }

  public static postfix func + (base: Self) -> OneOrMany<Self> {
    OneOrMany(base)
  }

  public static postfix func * (base: Self) -> ZeroOrMany<Self> {
    ZeroOrMany(base)
  }

}

/// Creates a `Maybe` combinator that wraps `base`.
public func maybe<Base: Combinator>(_ base: Base) -> Maybe<Base> {
  Maybe(base)
}

/// Creates a `ChooseN` combinator that wraps `bases`.
public func oneOf<S: Sequence, Base: Combinator>(_ bases: S) -> ChooseN<Base>
where S.Element == Base
{
  ChooseN(bases)
}

/// Creates a `OneOrMany` combinator that wraps `base`.
public func oneOrMany<Base: Combinator>(_ base: Base) -> OneOrMany<Base> {
  OneOrMany(base)
}

/// Creates a `ZeroOrMany` combinator that wraps `base`.
public func zeroOrMany<Base: Combinator>(_ base: Base) -> ZeroOrMany<Base> {
  ZeroOrMany(base)
}
