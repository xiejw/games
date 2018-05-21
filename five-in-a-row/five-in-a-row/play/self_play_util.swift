import Foundation

func selfPlaysAndRecord(size: Int, numberToWin: Int, selfPlayTimeInSecs: Double, perMoveSimulationTimes: Int, recordStates: Bool, verbose: Int = 0) {
    let board = Board(size: size, numberToWin: numberToWin)

    let fName = "/Users/xiejw/Desktop/games.txt"

    var storage: CSVStorage?
    if recordStates {
        print("Saving games into \(fName)")
        storage = CSVStorage(fileName: fName, deleteFileIfExists: true)
    }

    func gameFn() -> Game {
        let game = Game(size: size, numberToWin: numberToWin)
        try! game.newMove(Move(x: 3, y: 3))
        return game
    }

    func policyFn() -> [Policy] {
        let policy_500_1 = MCTSBasedPolicy(name: "mcts_500_1", size: size,
                                           predictor: RandomPredictor(size: size),
                                           board: board, perMoveSimulationTimes: perMoveSimulationTimes)

        let policy_500_2 = MCTSBasedPolicy(name: "mcts_500_2", size: size,
                                           predictor: RandomPredictor(size: size),
                                           board: board, perMoveSimulationTimes: perMoveSimulationTimes)

        return [policy_500_1, policy_500_2]
    }

    selfPlays(gameFn: gameFn, policyFn: policyFn, board: board, storage: storage, playTimeInSecs: selfPlayTimeInSecs, verbose: verbose)
}
