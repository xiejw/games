// Reference: https://jeffbradberry.com/posts/2015/09/intro-to-monte-carlo-tree-search/

let numberToWin = 5
let size = 15
let maxMoves = 100
let calculationTime = 90.0

let board = Board(size: size, numberToWin: numberToWin)
let simulator = BoardSimulator(size: size, numberToWin: numberToWin)

let ai = MonteCarlo(boardSimulator: simulator,
                    maxMoves: maxMoves, calculationTime: calculationTime)

do {
  try board.newMove(Move(x:8, y:8))
  try board.newMove(Move(x:7, y:9))

  board.print()
  var move = ai.getNextMove(stateHistory: board.states)!
  
  try board.newMove(Move(x:8, y:9))
  try board.newMove(Move(x:8, y:10))
  board.print()
  
  ai.getNextMove(stateHistory: board.states)

} catch PlayError.invalidMove(let move) {
  print("The move: \(move) is invalid.")
}
