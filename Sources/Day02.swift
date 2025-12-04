import Algorithms

struct Day02: AdventDay {
  var data: String

  func part1() async throws -> Any {
    let ranges = data.lazy.split(separator: ",", omittingEmptySubsequences: true)
    return try ranges.flatMap { range in
      guard let (start, end) = range.tsplit(separator: "-"), let startInt = Int(start), let endInt = Int(end) else {
        throw ParseError(message: "Couldn't parse range: \(range)")
      }
      return (startInt...endInt).filter { id in isInvalidID(id) }
    }
    .map { $0 }
    .reduce(into: 0, +=)
  }
  
  func isInvalidID(_ id: Int) -> Bool {
    let digits = id.digits
    let (midpoint, remainder) = digits.count.quotientAndRemainder(dividingBy: 2)
    guard remainder == 0, midpoint != 0 else {
      return false
    }
    let front = digits[..<midpoint]
    let back = digits[midpoint...]
    return front.elementsEqual(back)
  }
  
  struct ParseError: Error {
    var message: String
  }
}
