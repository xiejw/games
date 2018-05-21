import Foundation

struct Configuration {
    var size: Int
    var numberToWin: Int
    var selfPlayTimeInSecs: Double
    var perMoveSimulationTimes: Int
    var recordStates: Bool
    var verbose: Int = 0
}

let configuration = Configuration(size: 8,
                                  numberToWin: 5,
                                  selfPlayTimeInSecs: 366.0,
                                  perMoveSimulationTimes: 1600,
                                  recordStates: true,
                                  verbose: 0)
print("Configuration:\n\(configuration)")

let humanPlay = false

if !humanPlay {
    selfPlaysAndRecord(size: configuration.size,
                       numberToWin: configuration.numberToWin,
                       selfPlayTimeInSecs: configuration.selfPlayTimeInSecs,
                       perMoveSimulationTimes: configuration.perMoveSimulationTimes,
                       recordStates: configuration.recordStates,
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
                                       predictor: DistributionPredictionWrapper(size: configuration.size),
                                       board: board,
                                       perMoveSimulationTimes: configuration.perMoveSimulationTimes,
                                       playMode: true,
                                       verbose: configuration.verbose)

    playWithHuman(game: game, policy: policyToPlay, board: board)
}
