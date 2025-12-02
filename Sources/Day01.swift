import Algorithms

struct Day01: AdventDay {
  var data: String
  
  let limit = 100

  func part1() async throws -> Any {
    var zeros = 0
    _ = try lines.reduce(into: 50) { (sum: inout Int, line) in
      guard let firstChar = line.first else { return }
      guard let movement = Int(String(line.dropFirst())) else {
        throw ParseError(message: "Unexpected end of line: \(line.dropFirst())")
      }
      switch firstChar {
      case "R":
        sum += movement
        if sum >= limit {
          sum = sum.quotientAndRemainder(dividingBy: limit).remainder
        }
      case "L":
        sum -= movement
        sum = sum.quotientAndRemainder(dividingBy: limit).remainder
        if sum < 0 {
          sum = sum + limit
        }
      default:
        throw ParseError(message: "Unexpected start of line: '\(firstChar)'")
      }
      if sum == 0 {
        zeros += 1
      }
    }
    return zeros
  }
  
  struct ParseError: Error {
    var message: String
  }
}
