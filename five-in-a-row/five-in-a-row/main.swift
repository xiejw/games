// Reference: https://jeffbradberry.com/posts/2015/09/intro-to-monte-carlo-tree-search/

let numberToWin = 5
let size = 15
let maxMoves = 100
let calculationTime = 90.0

let board = Board(size: size, numberToWin: numberToWin)

do {
  try board.newMove(Move(x:8, y:8))
  try board.newMove(Move(x:7, y:9))
  try board.newMove(Move(x:8, y:9))
  try board.newMove(Move(x:8, y:10))
  board.print()
  
  let simulator = BoardSimulator(size: size, numberToWin: numberToWin)
  print("Legal moves left: \(simulator.legalMoves(stateHistory: board.states).count)")
  print("Next Player: \(simulator.nextPlayer(state: board.states.last!))")
  if let winner = simulator.winner(stateHistory: board.states) {
    print("Winner: \(winner)")
  } else {
    print("No winner yet")
  }
  
  print("Get next move.")
  let ai = MonteCarlo(boardSimulator: simulator,
                      maxMoves: maxMoves, calculationTime: calculationTime)
  ai.getNextMove(stateHistory: board.states)

} catch PlayError.invalidMove(let move) {
  print("The move: \(move) is invalid.")
}
