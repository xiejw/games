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
                                           predictor: DistributionPredictionWrapper(size: size),
                                           board: board, perMoveSimulationTimes: perMoveSimulationTimes)

        let policy_500_2 = MCTSBasedPolicy(name: "mcts_500_2", size: size,
                                           predictor: DistributionPredictionWrapper(size: size),
                                           board: board, perMoveSimulationTimes: perMoveSimulationTimes)

        return [policy_500_1, policy_500_2]
    }

    selfPlays(gameFn: gameFn, policyFn: policyFn, board: board, storage: storage, playTimeInSecs: selfPlayTimeInSecs, verbose: verbose)
}

func selfPlaysAndRating(size: Int, numberToWin: Int, policyFn: @escaping () -> [Policy], selfPlayTimeInSecs: Double, perMoveSimulationTimes _: Int, verbose: Int = 0) {
    let board = Board(size: size, numberToWin: numberToWin)

    func gameFn() -> Game {
        let game = Game(size: size, numberToWin: numberToWin)
        try! game.newMove(Move(x: 3, y: 3))
        return game
    }

    selfPlays(gameFn: gameFn, policyFn: policyFn, board: board, playTimeInSecs: selfPlayTimeInSecs, verbose: verbose)
}

func playWithHuman(size: Int, numberToWin: Int, perMoveSimulationTimes: Int, humanPlayer: Player = .WHITE, verbose: Int = 0) {
    let board = Board(size: size, numberToWin: numberToWin)
    let game = Game(size: size, numberToWin: numberToWin)
    try! game.newMove(Move(x: 3, y: 3))
    game.print()

    let policy = MCTSBasedPolicy(name: "mcts",
                                 size: size,
                                 predictor: DistributionPredictionWrapper(size: size),
                                 board: board,
                                 perMoveSimulationTimes: perMoveSimulationTimes,
                                 playMode: true,
                                 verbose: verbose)

    while true {
        let nextPlayer = game.stateHistory().last!.nextPlayer
        print("Next player is \(nextPlayer)")

        var move: Move
        if nextPlayer == humanPlayer {
            move = getMoveFromUser(validateFn: { (move: Move) -> Error? in
                game.validateNewMove(move)
            })
        } else {
            let history = game.stateHistory()
            let legalMoves = board.legalMoves(stateHistory: history)
            (move, _) = policy.getNextMove(stateHistory: history, legalMoves: legalMoves, explore: false)
        }
        print("Push move \(move)")
        try! game.newMove(move)

        game.print()
        if let winner = board.winner(stateHistory: game.stateHistory()) {
            print("We have a winner \(winner)")
            break
        }
    }
}
