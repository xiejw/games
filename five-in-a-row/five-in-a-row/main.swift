import Foundation

let numberToWin = 5
let size = 8
let selfPlayTime = 30.0 // <-
let calculationTime = 300.0
let humanPlay = false
let saveStates = false // <-
let fName = "/Users/xiejw/Desktop/games.txt"

let game = Game(size: size, numberToWin: numberToWin)
let simulator = GameSimulator(size: size, numberToWin: numberToWin)

var storage: Storage? = nil
if saveStates && !humanPlay {
  print("Saving games into \(fName)")
  storage = CSVStorage(fileName: fName, deleteFileIfExists: false)
}

// let predictor = RandomPredictor()
let ai = ImprovedMCTS(gameSimulator: simulator,
                      predictorFn: { StatePredictionWrapper(size: size) },
                      storage: storage)

try! game.newMove(Move(x:3, y:3))
try! game.newMove(Move(x:3, y:4))

game.print()

if !humanPlay {
  ai.selfPlay(stateHistory: game.states, calculationTime: selfPlayTime)
  exit(0)
}

// Play with human
playWithHuman(game: game, ai: ai, simulator: simulator)
