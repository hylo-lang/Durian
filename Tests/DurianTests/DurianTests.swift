import XCTest
import Durian

final class DurianTests: XCTestCase {

  func testApply() {
    let anyCharacter = Apply<Substring, Character>({ (context) in
      context.popFirst()
    })

    let input = "abc"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try anyCharacter.parse(&context), "a")
    XCTAssertEqual(context, "bc")
  }

  func testBind() throws {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let aAndA = a.bind({ (ch) in PopFirst(if: { $0 == ch }) })

    let input = "aab"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try aAndA.parse(&context), "a")
    XCTAssertEqual(context, "b")
  }

  func testChooseFirst() {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let b = PopFirst<Substring>(if: { $0 == "b" })
    let aOrB = a.or(b)

    let input = "abc"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try aOrB.parse(&context), "a")
    XCTAssertEqual(context, "bc")
  }

  func testChooseSecond() {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let b = PopFirst<Substring>(if: { $0 == "b" })
    let aOrB = a.or(b)

    let input = "bac"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try aOrB.parse(&context), "b")
    XCTAssertEqual(context, "ac")
  }

  func testChooseNFirst() {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let b = PopFirst<Substring>(if: { $0 == "b" })
    let aOrB = oneOf([a, b])

    let input = "abc"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try aOrB.parse(&context), "a")
    XCTAssertEqual(context, "bc")
  }

  func testChooseNSecond() {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let b = PopFirst<Substring>(if: { $0 == "b" })
    let aOrB = oneOf([a, b])

    let input = "bac"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try aOrB.parse(&context), "b")
    XCTAssertEqual(context, "ac")
  }

  func testCombine() throws {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let b = PopFirst<Substring>(if: { $0 == "b" })
    let aAndB = a.and(b)

    let input = "abc"
    var context = input.suffix(from: input.startIndex)
    let (first, second) = try XCTUnwrap(try aAndB.parse(&context))
    XCTAssertEqual(first, "a")
    XCTAssertEqual(second, "b")
    XCTAssertEqual(context, "c")
  }

  func testCombineWithCustomHardFailure() throws {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let b = PopFirst<Substring>(if: { $0 == "b" })
    let aAndB = a.and(b, else: { _ in TaggedError(tag: 42) })

    let input = "ac"
    var context = input.suffix(from: input.startIndex)
    do {
      _ = try aAndB.parse(&context)
      XCTFail("expected hard failure")
    } catch let error {
      let e = try XCTUnwrap(error as? TaggedError)
      XCTAssertEqual(e.tag, 42)
      XCTAssertEqual(context, "c")
    }
  }

  func testMaybeSucess() {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let maybeA = maybe(a)

    let input = "abc"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try maybeA.parse(&context), .some("a"))
    XCTAssertEqual(context, "bc")
  }

  func testMaybeFailure() {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let maybeA = maybe(a)

    let input = "bac"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try maybeA.parse(&context), .some(nil))
    XCTAssertEqual(context, "bac")
  }

  func testMaybeCollapsing() {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let b = PopFirst<Substring>(if: { $0 == "b" })
    let maybeAAndB = maybe(a).andCollapsingSoftFailures(b)

    let input = "cc"
    var context = input.suffix(from: input.startIndex)
    XCTAssertNil(try maybeAAndB.parse(&context))
    XCTAssertEqual(context, "cc")
  }

  func testMaybeCollapsingWithCustomHardFailure() throws {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let b = PopFirst<Substring>(if: { $0 == "b" })
    let maybeAAndB = maybe(a).andCollapsingSoftFailures(b, else: { _ in TaggedError(tag: 42) })

    let input = "ac"
    var context = input.suffix(from: input.startIndex)
    do {
      _ = try maybeAAndB.parse(&context)
      XCTFail("expected hard failure")
    } catch let error {
      let e = try XCTUnwrap(error as? TaggedError)
      XCTAssertEqual(e.tag, 42)
      XCTAssertEqual(context, "c")
    }
  }

  func testOneOrMany() {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let oneOrManyA = a+

    let input = "aabc"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try oneOrManyA.parse(&context), ["a", "a"])
    XCTAssertEqual(context, "bc")
  }

  func testOneOrManyNone() {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let oneOrManyA = a+

    let input = "bac"
    var context = input.suffix(from: input.startIndex)
    XCTAssertNil(try oneOrManyA.parse(&context))
    XCTAssertEqual(context, "bac")
  }

  func testPopFirst() {
    let a = PopFirst<Substring>(if: { $0 == "a" })

    let input = "abc"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try a.parse(&context), "a")
    XCTAssertEqual(context, "bc")
  }

  func testRecursive() {
    enum Parser {

      static let prefix: Recursive<Substring, String> = Recursive(_prefix.parse(_:))

      static let _prefix = PopFirst<Substring>(if: { $0 == "a" }).and(maybe(prefix))
        .map({ (context, tree) -> String in
          String(tree.0) + (tree.1 ?? "")
        })
    }

    let input = "aabc"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try Parser.prefix.parse(&context), "aa")
    XCTAssertEqual(context, "bc")
  }

  func testTransform() {
    let aInAscii = PopFirst<Substring>(if: { $0 == "a" })
      .map({ (context, character) in character.asciiValue! })

    let input = "abc"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try aInAscii.parse(&context), 97)
    XCTAssertEqual(context, "bc")
  }

  func testTryCatchSuccess() {
    let a = PopFirst<Substring>(if: { $0 == "a" })
      .map({ (context, character) -> String in String(character) })
    let b = PopFirst<Substring>(if: { $0 == "b" })
      .map({ (context, character) -> String in String(character) })
    let aAndB = a.and(b)
      .map({ (context, tree) -> String in tree.0 + tree.1 })

    let aAndBorB = TryCatch(trying: aAndB, orCatchingAndApplying: b)

    let input = "abc"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try aAndBorB.parse(&context), "ab")
    XCTAssertEqual(context, "c")
  }

  func testTryCatchFailure() {
    let a = PopFirst<Substring>(if: { $0 == "a" })
      .map({ (context, character) -> String in String(character) })
    let b = PopFirst<Substring>(if: { $0 == "b" })
      .map({ (context, character) -> String in String(character) })
    let aAndB = a.and(b)
      .map({ (context, tree) -> String in tree.0 + tree.1 })

    let aAndBorB = TryCatch(trying: aAndB, orCatchingAndApplying: b)

    let input = "bac"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try aAndBorB.parse(&context), "b")
    XCTAssertEqual(context, "ac")
  }

  func testZeroOrMany() {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let zeroOrManyA = a*

    let input = "aabc"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try zeroOrManyA.parse(&context), ["a", "a"])
    XCTAssertEqual(context, "bc")
  }

  func testZeroOrManyNone() {
    let a = PopFirst<Substring>(if: { $0 == "a" })
    let zeroOrManyA = a*

    let input = "bac"
    var context = input.suffix(from: input.startIndex)
    XCTAssertEqual(try zeroOrManyA.parse(&context), [])
    XCTAssertEqual(context, "bac")
  }

}

struct TaggedError: Error {

  let tag: Int

}

extension Substring: Restorable {

  public func backup() -> Substring { self }

  public mutating func restore(from backup: Substring) { self = backup }

}
