// Reference: https://jeffbradberry.com/posts/2015/09/intro-to-monte-carlo-tree-search/

let numberToWin = 5
let size = 8
let maxMoves = 150
let calculationTime = 300.0
let warmUpTime = 600.0
let humanPlay = true

let board = Board(size: size, numberToWin: numberToWin)
let simulator = BoardSimulator(size: size, numberToWin: numberToWin)

let ai = MonteCarlo(boardSimulator: simulator,
                    maxMoves: maxMoves,
                    calculationTime: calculationTime,
                    randomOnly: false)

do {
  try board.newMove(Move(x:3, y:3))
  board.print()
  
  print("Warm up")
  ai.warmUp(stateHistory: board.states, warmupTime: warmUpTime)
  
  while true {
    let nextPlayer = simulator.nextPlayer(state: board.states.last!)
    print("Next player is \(nextPlayer)")
    
    var move: Move
    if nextPlayer == .WHITE && humanPlay {
      print("x: ", terminator: "")
      let x = Int(readLine()!)!
      print("y: ", terminator: "")
      let y = Int(readLine()!)!
      move = Move(x:x, y:y)
    } else {
      move = ai.getNextMove(stateHistory: board.states)!
    }
    print("Push move \(move)")
    
    try board.newMove(move)
    board.print()
    if let winner = simulator.winner(stateHistory: board.states) {
      print("We have a winner \(winner)")
      break
    }
  }
  
} catch PlayError.invalidMove(let move) {
  print("The move: \(move) is invalid.")
}
