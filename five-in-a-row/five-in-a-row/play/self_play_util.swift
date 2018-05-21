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

func selfPlaysAndRating(size: Int, numberToWin: Int, selfPlayTimeInSecs: Double, perMoveSimulationTimes: Int, verbose: Int = 0) {
    let board = Board(size: size, numberToWin: numberToWin)
    let eachRatingTimeInSecs = selfPlayTimeInSecs / 3

    func gameFn() -> Game {
        let game = Game(size: size, numberToWin: numberToWin)
        try! game.newMove(Move(x: 3, y: 3))
        return game
    }

    func policyFn1() -> [Policy] {
        let mctsPolicy = MCTSBasedPolicy(name: "mcts", size: size,
                                         predictor: DistributionPredictionWrapper(size: size),
                                         board: board, perMoveSimulationTimes: perMoveSimulationTimes)

        let randomPolicy = RandomPolicy(name: "random")

        return [mctsPolicy, randomPolicy]
    }

    selfPlays(gameFn: gameFn, policyFn: policyFn1, board: board, playTimeInSecs: eachRatingTimeInSecs, verbose: verbose)

    func policyFn2() -> [Policy] {
        let mctsPolicy = MCTSBasedPolicy(name: "mcts", size: size,
                                         predictor: DistributionPredictionWrapper(size: size),
                                         board: board, perMoveSimulationTimes: perMoveSimulationTimes)

        let randomPredictorPolicy = MCTSBasedPolicy(name: "mcts_random_predictor", size: size,
                                                    predictor: RandomPredictor(size: size),
                                                    board: board, perMoveSimulationTimes: perMoveSimulationTimes)

        return [mctsPolicy, randomPredictorPolicy]
    }

    selfPlays(gameFn: gameFn, policyFn: policyFn2, board: board, playTimeInSecs: eachRatingTimeInSecs, verbose: verbose)

    func policyFn3() -> [Policy] {
        let mctsPolicy = MCTSBasedPolicy(name: "mcts", size: size,
                                         predictor: DistributionPredictionWrapper(size: size),
                                         board: board, perMoveSimulationTimes: perMoveSimulationTimes)

        let mctsLastIterationPolicy = MCTSBasedPolicy(name: "mcts_last_iteration", size: size,
                                                      predictor: DistributionPredictionForLastIterationWrapper(size: size),
                                                      board: board, perMoveSimulationTimes: perMoveSimulationTimes)

        return [mctsPolicy, mctsLastIterationPolicy]
    }

    selfPlays(gameFn: gameFn, policyFn: policyFn3, board: board, playTimeInSecs: eachRatingTimeInSecs, verbose: verbose)
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
            (move, _) = policy.getNextMove(stateHistory: history, legalMoves: legalMoves)
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
