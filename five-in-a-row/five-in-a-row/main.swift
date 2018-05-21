// NEED Examine.
import Foundation

struct Configuration {
    var size: Int
    var numberToWin: Int
    var selfPlayTimeInSecs: Double
    var perMoveSimulationTimes: Int
    var verbose: Int = 0
}

let configuration = Configuration(size: 8,
                                  numberToWin: 5,
                                  selfPlayTimeInSecs: 6.0,
                                  perMoveSimulationTimes: 1600,
                                  verbose: 1)
print("Configuration:\n\(configuration)")

let humanPlay = false
// let saveStates = false
// let fName = "/Users/xiejw/Desktop/games.txt"

if !humanPlay {
    selfPlaysAndRecord(size: configuration.size,
                       numberToWin: configuration.numberToWin,
                       selfPlayTimeInSecs: configuration.selfPlayTimeInSecs,
                       perMoveSimulationTimes: configuration.perMoveSimulationTimes,
                       verbose: configuration.verbose)
    exit(0)
} else {
    // Play with human
    let board = Board(size: configuration.size, numberToWin: configuration.numberToWin)
    let game = Game(size: configuration.size, numberToWin: configuration.numberToWin)
    try! game.newMove(Move(x: 3, y: 3))
    game.print()

    let policyToPlay = MCTSBasedPolicy(name: "mcts",
                                       size: configuration.size,
                                       predictor: RandomPredictor(size: configuration.size),
                                       board: board,
                                       perMoveSimulationTimes: configuration.perMoveSimulationTimes,
                                       shouldRecord: false,
                                       playMode: true,
                                       verbose: configuration.verbose)

    playWithHuman(game: game, policy: policyToPlay, board: board)
}

// {{{1
// Play with premade Games
// premadePlay3()
