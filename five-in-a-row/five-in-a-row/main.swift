import Foundation

let numberToWin = 5
let size = 8
let selfPlayTime = 2400.0
let calculationTime = 60.0
let humanPlay = false
let saveStates = true
let fName = "/Users/xiejw/Desktop/games.txt"

let game = Game(size: size, numberToWin: numberToWin)
let simulator = GameSimulator(size: size, numberToWin: numberToWin)

var storage: Storage? = nil
if saveStates && !humanPlay {
  print("Saving games into \(fName)")
  storage = CSVStorage(fileName: fName, deleteFileIfExists: false)
}

let ai = ImprovedMCTS(gameSimulator: simulator,
                      storage: storage)

try! game.newMove(Move(x:3, y:3))

game.print()

if !humanPlay {
  ai.selfPlay(stateHistory: game.states, calculationTime: selfPlayTime)
  exit(0)
}

// Play with human

while true {
  let nextPlayer = game.states.last!.nextPlayer
  print("Next player is \(nextPlayer)")

  var move: Move
  if nextPlayer == .WHITE && humanPlay {
    move = getMoveFromUser(validateFn: {(move: Move) -> Error? in
      return game.validateNewMove(move)
    })
  } else {
    move = ai.getNextMove(stateHistory: game.states, calculationTime: calculationTime)!
  }
  print("Push move \(move)")
  try! game.newMove(move)

  game.print()
  if let winner = simulator.winner(stateHistory: game.states) {
    print("We have a winner \(winner)")
    break
  }
}

