//
//  DigitsCollectionTests.swift
//  AdventOfCode
//
//  Created by Joseph Van Boxtel on 12/3/25.
//

@testable import AdventOfCode
import Testing

struct DigitsCollectionTests {
  @Test
  func testDigits() {
    #expect(Array(DigitsCollection(integer: 12345)) == [5, 4, 3, 2, 1])
    #expect(Array(DigitsCollection(integer: 1)) == [1])
    #expect(Array(DigitsCollection(integer: 90)) == [0, 9])
    #expect(Array(DigitsCollection(integer: 8090)) == [0, 9, 0, 8])
  }
}
