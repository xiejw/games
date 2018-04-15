import Foundation

let numberToWin = 5
let size = 8
let selfPlayTime = 30.0 // <-
let calculationTime = 300.0
let humanPlay = false
let saveStates = true // <-
let fName = "/Users/xiejw/Desktop/games.txt"


let board = Board(size: size, numberToWin: numberToWin)

var storage: CSVStorage? = nil
if saveStates && !humanPlay {
  print("Saving games into \(fName)")
  storage = CSVStorage(fileName: fName, deleteFileIfExists: false)
}

if !humanPlay {
  func gameFn() -> Game {
    let game = Game(size: size, numberToWin: numberToWin)
    try! game.newMove(Move(x:3, y:3))
    return game
  }
  
  func policyFn() -> [Policy] {
    let policy = DistributionBasedPolicy(name: "dist_based", size: size,
                                         distributionGenerator: DistributionPredictionWrapper(size: size))
    let randomPolicy = RandomPolicy(name: "random_policy")
    return [policy, randomPolicy]
  }

  selfPlays(gameFn: gameFn, policyFn: policyFn, board: board, storage: storage, playTimeInSecs: selfPlayTime, verbose: 0)
  exit(0)
}

// Play with human
// playWithHuman(game: game, ai: ai, board: board)
