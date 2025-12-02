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
  
  func part2() async throws -> Any {
    var zeros = 0
    _ = try lines.reduce(into: 50) { (sum: inout Int, line) in
      guard let firstChar = line.first else { return }
      guard let movement = Int(String(line.dropFirst())) else {
        throw ParseError(message: "Unexpected end of line: \(line.dropFirst())")
      }
      defer { print(sum, zeros, line) }
      switch firstChar {
      case "R":
        for _ in 0..<movement {
          sum += 1
          if sum >= limit {
            zeros += 1
            sum -= limit
          }
        }
      case "L":
        for _ in 0..<movement {
          sum -= 1
          if sum == 0 {
            zeros += 1
          } else if sum < 0 {
            sum += limit
          }
        }
      default:
        throw ParseError(message: "Unexpected start of line: '\(firstChar)'")
      }
      
    }
    return zeros
  }
  
  func part21() async throws -> Any {
    var zeros = 0
    _ = try lines.reduce(into: 50) { (sum: inout Int, line) in
      guard let firstChar = line.first else { return }
      guard let movement = Int(String(line.dropFirst())) else {
        throw ParseError(message: "Unexpected end of line: \(line.dropFirst())")
      }
      defer { print(sum, zeros, line) }
      switch firstChar {
      case "R":
        sum += movement
        if sum >= limit {
          let (quotient, remainder) = sum.quotientAndRemainder(dividingBy: limit)
          zeros += quotient
          sum = remainder
        } else if sum == 0 {
          zeros += 1
        }
      case "L":
        sum -= movement
        let (quotient, remainder) = sum.quotientAndRemainder(dividingBy: limit)
        zeros += quotient
        sum = remainder
        if sum < 0 {
          sum = sum + limit
          zeros += 1
        } else if sum == 0 {
          zeros += 1
        }
        assert((0..<limit).contains(sum))
      default:
        throw ParseError(message: "Unexpected start of line: '\(firstChar)'")
      }
      
    }
    return zeros
  }
  
  struct ParseError: Error {
    var message: String
  }
}
