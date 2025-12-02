import Testing

@testable import AdventOfCode

struct Day01Tests: AdventDaySuite {
  
  let sample = """
  L68
  L30
  R48
  L5
  R60
  L55
  L1
  L99
  R14
  L82
  """
  
  @Test func part1() async throws {
    let output = try await part1(on: sample)
    #expect(output == "3")
  }
  @Test func part1R50() async throws {
    let output = try await part1(on: """
    R50
    R50
    R50
    """)
    #expect(output == "2")
  }
  @Test func part1L50() async throws {
    let output = try await part1(on: """
    L50
    L50
    L50
    """)
    #expect(output == "2")
  }
  @Test func part1R150() async throws {
    let output = try await part1(on: """
    R150
    """)
    #expect(output == "1")
  }
  @Test func part1L150() async throws {
    let output = try await part1(on: """
    L150
    """)
    #expect(output == "1")
  }

  
  
  @Test func part2() async throws {
    let output = try await part2(on: sample)
    #expect(output == "6")
  }
  
  @Test func part2R50() async throws {
    let output = try await part2(on: """
    R50
    R50
    R50
    """)
    #expect(output == "2")
  }
  @Test func part2L50() async throws {
    let output = try await part2(on: """
    L50
    L50
    L50
    """)
    #expect(output == "2")
  }
  @Test func part2R150() async throws {
    let output = try await part2(on: """
    R150
    """)
    #expect(output == "2")
  }
  @Test func part2L150() async throws {
    let output = try await part2(on: """
    L150
    """)
    #expect(output == "2")
  }

}
