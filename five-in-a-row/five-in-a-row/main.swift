let board = Board()

do {
  try board.newMove(Move(x:4, y:4))
  try board.newMove(Move(x:2, y:3))
  try board.newMove(Move(x:4, y:3))
  try board.newMove(Move(x:3, y:4))
  board.print()
  
  let simulator = BoardSimulator(size:8)
  print("Legal moves left: \(simulator.legal_moves(state_history: board.states).count)")
  print("Next Player: \(simulator.next_player(state: board.states.last!))")
  if let winner = simulator.winner(state_history: board.states) {
    print("Winner: \(winner)")
  } else {
    print("No winner yet")
  }
  
} catch PlayError.invalidMove(let move) {
  print("The move: \(move) is invalid.")
}
