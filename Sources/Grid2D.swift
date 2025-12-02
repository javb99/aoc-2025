

struct GridPoint: Hashable, Comparable, CustomStringConvertible {
  var row: Int
  var column: Int

  static func < (_ lhs: Self, _ rhs: Self) -> Bool {
    return (lhs.row, rhs.column) < (rhs.row, rhs.column)
  }
  
  var description: String {
    return "(r: \(row), c: \(column))"
  }
  
  func vector(to other: Self) -> GridVector {
    GridVector(rows: other.row - row, columns: other.column - column)
  }
  
  func moved(by vector: GridVector) -> Self {
    GridPoint(row: row + vector.rows, column: column + vector.columns)
  }
}
struct GridVector: Hashable, CustomStringConvertible {
  var rows: Int
  var columns: Int
  
  var description: String {
    return "(r: \(rows), c: \(columns))"
  }
  
  func inverted() -> Self {
    GridVector(rows: -rows, columns: -columns)
  }
}

struct Grid2D<Cell> {
  var rows: [[Cell]]

  var columnsCount: Int {
    rows[0].count
  }
  
  init(rows: [[Cell]]) {
    self.rows = rows
  }

  init(cells: some RandomAccessCollection<Cell>, cellsPerRow: Int) {
    self.rows = Array(cells.chunks(ofCount: cellsPerRow).map(Array.init))
  }
  
  func map<NewCell>(_ transform: (Cell) throws -> NewCell) rethrows -> Grid2D<NewCell> {
    Grid2D<NewCell>(rows: try rows.map { row in
      try row.map(transform)
    })
  }
  
  func mapByPoint<NewCell>(_ transform: (_ point: GridPoint, _ cell: Cell) throws -> NewCell) rethrows -> Grid2D<NewCell> {
    Grid2D<NewCell>(rows: try rows.enumerated().map { row, rowContents in
      return try rowContents.enumerated().map { column, cell in
        return try transform(GridPoint(row: row, column: column), cell)
      }
    })
  }
  
  mutating func visualize(_ locations: some Sequence<GridPoint>, as render: (GridPoint) -> Cell) {
    for point in locations {
      self[point] = render(point)
    }
  }
  
  func flatMap<NewCell>(_ transform: (_ cell: Cell) throws -> Grid2D<NewCell>) rethrows -> Grid2D<NewCell> {
    precondition(rows.count > 0)
    precondition(columnsCount > 0)
    return try rows.map { row in
      return try row.map { cell in
        return try transform(cell)
      }.reduce { partial, expandedCell in
        partial.appendColumns(of: expandedCell)
      }!
    }.reduce { partial, expandedRow in
      partial.appendRows(of: expandedRow)
    }!
  }
  
  mutating func appendColumns(of grid: Self) {
    precondition(grid.rows.count == rows.count, "appending columns requires the grids to be the same height")
    
    for row in 0..<grid.rows.count {
      rows[row].append(contentsOf: grid.rows[row])
    }
  }
  
  mutating func appendRows(of grid: Self) {
    precondition(grid.columnsCount == columnsCount, "appending rows requires the grids to be the same width")
    
    rows.append(contentsOf: grid.rows)
  }

  subscript(row: Int, column: Int) -> Cell {
    return rows[row][column]
  }
  
  subscript(point: GridPoint) -> Cell {
    get {
      return rows[point.row][point.column]
    }
    set {
      rows[point.row][point.column] = newValue
    }
  }
  
  subscript(safe point: GridPoint) -> Cell? {
    get {
      guard contains(point) else { return nil }
      return rows[point.row][point.column]
    }
  }

  subscript(row: Int, columns: ClosedRange<Int>) -> ArraySlice<Cell> {
    return rows[row][columns]
  }
  
  func contains(_ point: GridPoint) -> Bool {
    return rows.indices.contains(point.row) && columns.indices.contains(point.column)
  }

  func adjacentOf(row: Int, column: Int) -> [GridPoint] {
    var adjacentPoints: [GridPoint] = []
    if row > 0 {
      adjacentPoints.append(GridPoint(row: row - 1, column: column))
      if column > 0 {
        adjacentPoints.append(GridPoint(row: row - 1, column: column - 1))
      }
      if column < columnsCount-1 {
        adjacentPoints.append(GridPoint(row: row - 1, column: column + 1))
      }
    }
    if row < rows.count - 1 {
      adjacentPoints.append(GridPoint(row: row + 1, column: column))
      if column > 0 {
        adjacentPoints.append(GridPoint(row: row + 1, column: column - 1))
      }
      if column < columnsCount-1 {
        adjacentPoints.append(GridPoint(row: row + 1, column: column + 1))
      }
    }
    if column > 0 {
      adjacentPoints.append(GridPoint(row: row, column: column - 1))
    }
    if column < columnsCount-1 {
      adjacentPoints.append(GridPoint(row: row, column: column + 1))
    }
    return adjacentPoints
  }

  func cardinalAdjacentOf(row: Int, column: Int) -> [GridPoint] {
    var adjacentPoints: [GridPoint] = []
    if row > 0 {
      adjacentPoints.append(GridPoint(row: row - 1, column: column))
    }
    if row < rows.count - 1 {
      adjacentPoints.append(GridPoint(row: row + 1, column: column))
    }
    if column > 0 {
      adjacentPoints.append(GridPoint(row: row, column: column - 1))
    }
    if column < columnsCount-1 {
      adjacentPoints.append(GridPoint(row: row, column: column + 1))
    }
    return adjacentPoints
  }
}

extension Grid2D {
  func stride(by step: GridVector, from start: GridPoint) -> some Sequence<GridPoint> {
    return sequence(first: start) { previous in
      let next = previous.moved(by: step)
      if !self.contains(next) {
        return nil
      }
      return next
    }
  }
}

extension Grid2D<Character>: CustomStringConvertible {
  init(_ string: some StringProtocol) {
    self.init(rows: Array(string.lazy
      .split(separator: "\n")
      .map { line in
        Array(line)
      }))
  }
  
  var description: String {
    var description: String = ""
    for row in rows {
      for character in row {
        description.append(character)
      }
      description += "\n"
    }
    return description
  }
}

extension Grid2D: Collection {
  typealias Index = GridPoint
  typealias Element = (point: GridPoint, cell: Cell)
  var startIndex: Index {
    return GridPoint(row: 0, column: 0)
  }
  var endIndex: Index {
    return GridPoint(row: rows.endIndex, column: 0)
  }
  subscript(i: Index) -> Element {
    return (i, self[i])
  }
  func index(after i: Index) -> GridPoint {
    var next = i
    next.column += 1
    if next.column == columnsCount {
      next.row += 1
      next.column = 0
    }
    return next
  }
}

extension Grid2D {
  var pointsByRow: PointsByRow {
    PointsByRow(rowCount: rows.count, columnCount: columnsCount)
  }
  struct PointsByRow: Collection {
    var rowCount: Int
    var columnCount: Int
    typealias Index = GridPoint
    var startIndex: Index {
      return GridPoint(row: 0, column: 0)
    }
    var endIndex: Index {
      return GridPoint(row: rowCount, column: 0)
    }
    subscript(i: Index) -> GridPoint {
      return i
    }
    func index(after i: Index) -> GridPoint {
      var next = i
      next.column += 1
      if next.column == columnCount {
        next.row += 1
        next.column = 0
      }
      return next
    }
  }
  var cells: Cells {
    Cells(base: self)
  }
  struct Cells: Collection {
    fileprivate var base: Grid2D

    typealias Index = GridPoint
    var startIndex: GridPoint {
      return GridPoint(row: 0, column: 0)
    }
    var endIndex: GridPoint {
      return GridPoint(row: base.rows.endIndex, column: 0)
    }
    subscript(i: GridPoint) -> Cell {
      return base.rows[i.row][i.column]
    }
    func index(after i: Index) -> GridPoint {
      var next = i
      next.column += 1
      if next.column == base.rows[next.row].endIndex {
        next.row += 1
        next.column = 0
      }
      return next
    }
  }
//  subscript(column column: Int) -> Column {
//    return Column(base: self, column: column)
//  }
  var columns: Columns {
    return Columns(base: self)
  }
  struct Columns: Collection {
    fileprivate var base: Grid2D

    // the row index
    typealias Index = Int
    var startIndex: Index {
      return 0
    }
    var endIndex: Index {
      return base.columnsCount
    }
    typealias Indices = Range<Index>
    var indices: Indices {
      startIndex..<endIndex
    }
    subscript(column: Index) -> Column {
      return Column(base: base, column: column)
    }
    func index(after i: Index) -> Index {
      return i + 1
    }
  }
  struct Column: Collection {
    fileprivate var base: Grid2D
    fileprivate var column: Int

    // the row index
    typealias Index = Int
    var startIndex: Index {
      return base.rows.startIndex
    }
    var endIndex: Index {
      return base.rows.endIndex
    }
    subscript(i: Index) -> Cell {
      return base.rows[i][column]
    }
    func index(after i: Index) -> Index {
      return base.rows.index(after: i)
    }
  }
}
extension Grid2D.Column: Equatable where Cell: Equatable {
  static func == (lhs: Grid2D<Cell>.Column, rhs: Grid2D<Cell>.Column) -> Bool {
    lhs.elementsEqual(rhs)
  }
}

enum Direction: Hashable, CaseIterable {
  case up
  case down
  case left
  case right
  
  var inverse: Self {
    switch self {
    case .up:
      return .down
    case .down:
      return .up
    case .left:
      return .right
    case .right:
      return .left
    }
  }
  
  var rotateClockwise90Degrees: Self {
    switch self {
    case .up:
        .right
    case .left:
        .up
    case .right:
        .down
    case .down:
        .left
    }
  }
}

enum DirectionWithDiagonals: Hashable, CaseIterable {
  case north
  case northWest
  case northEast
  case west
  case east
  case southWest
  case south
  case southEast
  
  var inverse: Self {
    switch self {
    case .north:
        .south
    case .northWest:
        .southEast
    case .northEast:
        .southWest
    case .west:
        .east
    case .east:
        .west
    case .southWest:
        .northEast
    case .south:
        .north
    case .southEast:
        .northWest
    }
  }
//  
//  var rotateClockwise90Degrees: Self {
//    switch self {
//    case .north:
//        .east
//    case .northWest:
//        .northEast
//    case .northEast:
//        .southEast
//    case .west:
//        .north
//    case .east:
//        .south
//    case .southWest:
//        .northWest
//    case .south:
//        .west
//    case .southEast:
//        .southWest
//    }
//  }
}

extension GridPoint {
  func adding(_ amount: Int = 1, toward direction: DirectionWithDiagonals) -> GridPoint {
    var next = self
    next.add(amount, toward: direction)
    return next
  }
  func adding(_ amount: Int = 1, toward direction: Direction) -> GridPoint {
    var next = self
    next.add(amount, toward: direction)
    return next
  }
  mutating func add(_ amount: Int = 1, toward direction: DirectionWithDiagonals) {
    switch direction {
    case .north, .northWest, .northEast:
      row -= amount
    case .south, .southWest, .southEast:
      row += amount
    case .west, .east: break
    }
    
    switch direction {
    case .north, .south: break
    case .west, .northWest, .southWest:
      column -= amount
    case .east, .northEast, .southEast:
      column += amount
    }
  }
  mutating func add(_ amount: Int = 1, toward direction: Direction) {
    switch direction {
    case .up:
      row -= amount
    case .down:
      row += amount
    case .left:
      column -= amount
    case .right:
      column += amount
    }
  }
}
