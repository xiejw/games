// Reference: https://jeffbradberry.com/posts/2015/09/intro-to-monte-carlo-tree-search/

let numberToWin = 5
let size = 8
let maxMoves = 150
let calculationTime = 300.0
let warmUpTime = 0.0
let humanPlay = true
let saveStates = false

let game = Game(size: size, numberToWin: numberToWin)
let simulator = GameSimulator(size: size, numberToWin: numberToWin)

var storage: Storage? = nil
if saveStates {
  storage = CSVStorage(fileName: "/tmp/2333.txt", focusedPlayer: .BLACK)
}

let ai = MonteCarlo(gameSimulator: simulator,
                    maxMoves: maxMoves,
                    calculationTime: calculationTime,
                    randomOnly: false,
                    storage: storage)
// P [0.52925795] R 1.0 L 1,2,1,0,3,3,1,4,1,0,7,2,1

try! game.newMove(Move(x:3, y:3))
try! game.newMove(Move(x:2, y:1))
try! game.newMove(Move(x:7, y:2))
try! game.newMove(Move(x:4, y:1))
game.print()

print("Prob \(StatePredictionWrapper(size: size).predictWinning(state: game.states.last!))")

//if warmUpTime > 0.0 {
//  print("Warm up AI.")
//  ai.warmUp(stateHistory: game.states, warmupTime: warmUpTime)
//}
//
//while true {
//  let nextPlayer = game.states.last!.nextPlayer
//  print("Next player is \(nextPlayer)")
//
//
//  print("Prob \(StatePredictionWrapper(size: size).predictWinning(state: game.states.last!))")
//
//
//  var move: Move
//  if nextPlayer == .WHITE && humanPlay {
//    move = getMoveFromUser(validateFn: {(move: Move) -> Error? in
//      return game.validateNewMove(move)
//    })
//  } else {
//    move = ai.getNextMove(stateHistory: game.states)!
//  }
//  print("Push move \(move)")
//  try! game.newMove(move)
//
//  game.print()
//  if let winner = simulator.winner(stateHistory: game.states) {
//    print("We have a winner \(winner)")
//    break
//  }
//}

