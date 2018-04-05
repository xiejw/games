// Reference: https://jeffbradberry.com/posts/2015/09/intro-to-monte-carlo-tree-search/

let numberToWin = 5
let size = 8
let maxMoves = 150
let calculationTime = 300.0
let warmUpTime = 1200.0
let humanPlay = true

let game = Game(size: size, numberToWin: numberToWin)
let simulator = GameSimulator(size: size, numberToWin: numberToWin)

let ai = MonteCarlo(gameSimulator: simulator,
                    maxMoves: maxMoves,
                    calculationTime: calculationTime,
                    randomOnly: false)

do {
  try game.newMove(Move(x:3, y:3))
  game.print()
  
  print("Warm up AI.")
  ai.warmUp(stateHistory: game.states, warmupTime: warmUpTime)
  
  while true {
    let nextPlayer = game.states.last!.nextPlayer
    print("Next player is \(nextPlayer)")
    
    var move: Move
    if nextPlayer == .WHITE && humanPlay {
      print("x: ", terminator: "")
      let x = Int(readLine()!)!
      print("y: ", terminator: "")
      let y = Int(readLine()!)!
      move = Move(x:x, y:y)
    } else {
      move = ai.getNextMove(stateHistory: game.states)!
    }
    print("Push move \(move)")
    
    try game.newMove(move)
    game.print()
    if let winner = simulator.winner(stateHistory: game.states) {
      print("We have a winner \(winner)")
      break
    }
  }
  
} catch PlayError.invalidMove(let move) {
  print("The move: \(move) is invalid.")
}
