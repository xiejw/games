// NEED Examine.
import Foundation

let size = 8
let numberToWin = 5

let selfPlayTime = 2400.0 // <-
let humanPlay = false
let saveStates = true // <-
let fName = "/Users/xiejw/Desktop/games.txt"

let board = Board(size: size, numberToWin: numberToWin)

// var storage: CSVStorage?
// if saveStates && !humanPlay {
//    print("Saving games into \(fName)")
//    storage = CSVStorage(fileName: fName, deleteFileIfExists: false)
// }
//
// if !humanPlay {
//    func gameFn() -> Game {
//        let game = Game(size: size, numberToWin: numberToWin)
//        try! game.newMove(Move(x: 3, y: 3))
//        return game
//    }
//
//    func policyFn() -> [Policy] {
//        let policy_500 = MCTSBasedPolicy(name: "mcts_500_1", size: size,
//                                         distributionGenerator: DistributionPredictionWrapper(size: size),
//                                         board: board, perMoveSimulationTimes: 2000, shouldRecord: true)
//
//        let policy_100 = MCTSBasedPolicy(name: "mcts_500_2", size: size,
//                                         distributionGenerator: DistributionPredictionWrapper(size: size),
//                                         board: board, perMoveSimulationTimes: 2000, shouldRecord: true)
//
////    let policy = DistributionBasedPolicy(name: "dist_based", size: size,
////                                         distributionGenerator: DistributionPredictionWrapper(size: size))
//
//        return [policy_500, policy_100]
////     let randomPolicy = RandomPolicy(name: "random_policy")
////
////     return [policy_500, randomPolicy]
//    }
//
//    selfPlays(gameFn: gameFn, policyFn: policyFn, board: board, storage: storage, playTimeInSecs: selfPlayTime, verbose: 0)
//    exit(0)
// }

//// Play with human
// let game = Game(size: size, numberToWin: numberToWin)
//try! game.newMove(Move(x: 3, y: 3))
// game.print()
//
//// let policyToPlay = RandomPolicy()
// let policyToPlay = MCTSBasedPolicy(name: "mcts", size: size, predictor: RandomPredictor(size: size), board: board, perMoveSimulationTimes: 1600, shouldRecord: false, playMode: true, verbose: 1)
//
// playWithHuman(game: game, policy: policyToPlay, board: board)

// Play with human

premadePlay3()
