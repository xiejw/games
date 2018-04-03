// Reference: https://jeffbradberry.com/posts/2015/09/intro-to-monte-carlo-tree-search/

let numberToWin = 3
let size = 8

let board = Board(size: size, numberToWin: numberToWin)

do {
  try board.newMove(Move(x:4, y:4))
  try board.newMove(Move(x:2, y:3))
  try board.newMove(Move(x:5, y:3))
  try board.newMove(Move(x:3, y:4))
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
  let ai = MonteCarlo(boardSimulator: simulator, maxMoves: 10, calculationTime: 30)
  ai.getNextMove(stateHistory: board.states)

  
} catch PlayError.invalidMove(let move) {
  print("The move: \(move) is invalid.")
}
