import XCTest

@testable import AdventOfCode

// One off test to validate that basic data load testing works
final class AdventDayTests: XCTestCase {
  func testInitData() async throws {
    let challenge = Day00()
    XCTAssertEqual(challenge.data, "\n")
  }
}

protocol AdventDaySuite {
  static var day: Int { get }
}

extension AdventDaySuite {
  func Day(data: String) -> any AdventDay {
    let day = Self.day
    let metatype = allChallenges.first { $0.day == day }!
    return metatype.init(data: data)
  }
  
  func part1(on data: String) async throws -> String {
    return String(describing: try await Day(data: data).part1())
  }
  
  func part2(on data: String) async throws -> String {
    return String(describing: try await Day(data: data).part2())
  }
  
  // Find the challenge day from the type name.
  static var day: Int {
    let typeName = String(reflecting: Self.self).dropLast("Tests".count)
    guard let i = typeName.lastIndex(where: { !$0.isNumber }),
          let day = Int(typeName[i...].dropFirst())
    else {
      fatalError(
          """
          Day number not found in type name: \
          implement the static `day` property \
          or use the day number as your type's suffix (like `Day3`).")
          """)
    }
    return day
  }
}
