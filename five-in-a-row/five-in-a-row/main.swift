import Foundation

let numberToWin = 5
let size = 8
let selfPlayTime = 300.0 // <-
let calculationTime = 300.0
let humanPlay = false
let saveStates = true // <-
let fName = "/Users/xiejw/Desktop/games.txt"

let game = Game(size: size, numberToWin: numberToWin)
let board = Board(size: size, numberToWin: numberToWin)

var storage: Storage? = nil
if saveStates && !humanPlay {
  print("Saving games into \(fName)")
  storage = CSVStorage(fileName: fName, deleteFileIfExists: false)
}

// let predictor = RandomPredictor()
//let ai = ImprovedMCTS(board: board,
//                      predictorFn: { StatePredictionWrapper(size: size) },
//                      storage: storage)

try! game.newMove(Move(x:3, y:3))

game.print()

if !humanPlay {
  selfPlays(game: game, board: board, policies: [RandomPolicy(name: "policy_1"), RandomPolicy(name: "policy_2")], playTimeInSecs: 10)
  exit(0)
}

// Play with human
// playWithHuman(game: game, ai: ai, board: board)
