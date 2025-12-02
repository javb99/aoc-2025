import Testing

@testable import AdventOfCode

struct Day00Tests: AdventDaySuite {
  
  let sample1 = """
  NotImplementedYet
  """
  
  @Test func part1Sample1() async throws {
    let output = try await part1(on: sample1)
    #expect(output == "NotImplementedYet")
  }

  @Test func part2() async throws {
    let output = try await part2(on: sample1)
    #expect(output == "NotImplementedYet")
  }
}
