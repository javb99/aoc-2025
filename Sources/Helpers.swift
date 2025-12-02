//
//  Helpers.swift
//  AdventOfCode
//
//  Created by Joseph Van Boxtel on 12/1/24.
//

extension Collection where Element: Equatable {
  func tsplit(separator: Element) -> (Self.SubSequence, Self.SubSequence)? {
    let parts = self.split(maxSplits: 1, whereSeparator: { $0 == separator })
    guard parts.count >= 2 else {
      return nil
    }
    return (parts[0], parts[1])
  }
}

extension StringProtocol where SubSequence == Substring {
  func tsplit(separator: some RegexComponent) -> (Self.SubSequence, Self.SubSequence)? {
    guard let match = self.firstMatch(of: separator) else {
      return nil
    }
    return (self[..<match.range.lowerBound], self[match.range.upperBound...])
  }
}

extension Substring {
  func positiveInts() -> [Int] {
    self.matches(of: #/\d+/#).compactMap { match in
      return Int(match.output)
    }
  }
}

extension Sequence {
  /// Combine elements together to form a single element.
  func reduce(
    _ updateAccumulatingResult: (
      _ partialResult: inout Element,
      _ element: Element
    ) throws -> Void
  ) rethrows -> Element? {
    var iterator = makeIterator()
    guard var result = iterator.next() else {
      return nil
    }
    while let element = iterator.next() {
      try updateAccumulatingResult(&result, element)
    }
    return result
  }
}


extension Collection {
  var headAndRest: (Element, Self.SubSequence)? {
    guard let first else {
      return nil
    }
    return (first, dropFirst())
  }
}

func memoize<T: Hashable, R>(
  _ f: @escaping (T) -> R
) -> (T) -> R {
  var table: [T: R] = [:]
  return { input in
    table.lookupOrInsert(f(input), forKey: input).value
  }
}

extension Dictionary {
  mutating func lookupOrInsert(_ value: @autoclosure () -> Value, forKey key: Key) -> (value: Value, inserted: Bool) {
    { valueAtKey in
      if let v = valueAtKey {
        return (value: v, inserted: false)
      } else {
        let v = value()
        valueAtKey = v
        return (value: v, inserted: true)
      }
    }(&self[key])
  }
}


extension BinaryInteger where Self: Strideable, Self.Stride: SignedInteger {
  var numberOfBase10Digits: Int {
    var digits = 0
    var i = self
    while (i != 0) { i /= 10; digits += 1; }
    return digits
  }
  /// Returns `self * 10^n`
  func pow10(_ powerOfTen: Self) -> Self {
    return self * .pow10(powerOfTen)
  }
  /// Returns `10^powerOfTen`
  static func pow10(_ powerOfTen: Self) -> Self {
    precondition(powerOfTen > 0)
    var r = 1 as Self
    for _ in 1...powerOfTen {
      r *= 10
    }
    return r
  }
}

//extension StringProtocol where Self.SubSequence == Substring {
//  @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
//  public func vsplit<each S: StringProtocol>(
//    separator: Substring,
//    maxSplits: Int = .max,
//    omittingEmptySubsequences: Bool = true,
//    substrings: (repeat (each S).Type)
//  ) -> (repeat each S)? {
//    var portions: ArraySlice<Substring> = self.split(
//      separator: separator,
//      maxSplits: maxSplits,
//      omittingEmptySubsequences: omittingEmptySubsequences
//    )[...]
//    return (repeat replace((each S).self, with: portions.popFirst() as! each S))
//  }

//  @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
//  public func split2(
//    separator: Substring,
//    omittingEmptySubsequences: Bool = true
//  ) -> (Substring, Substring)? {
//    return self.vsplit(
//      separator: separator,
//      maxSplits: 2,
//      omittingEmptySubsequences: omittingEmptySubsequences,
//      substrings: (Substring.self, Substring.self)
//    ) as (Substring, Substring)?
//    let match = self.firstMatch(of: separator)
//    guard let separatorRange = match?.range else {
//      return nil
//    }
//    return
//  }
//}

//private struct NilError: Error { }
//func orThrow<T>() throws -> T {
//  throw NilError()
//}

//func zip<each T>(_ optional: (repeat (each T)?)) -> (repeat each T)? {
//  do {
//    return try (repeat (each optional) ?? orThrow())
//  } catch {
//    return nil
//  }
//}

//func replace<T, V>(_ ignored: T, with value: V) -> V {
//  return value
//}

//func map<each T, each R>(_ optional: (repeat each T), transform: (T) throws -> R) rethrows -> (repeat each R) where (repeat each T) == (repeat each R) {
//  try (repeat (each optional) ?? orThrow())
//}
