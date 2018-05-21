// Provides the tooling to play one Game or multiple Games.
import Foundation

func selfPlays(gameFn: @escaping () -> Game, policyFn: @escaping () -> [Policy], board: Board, storage: CSVStorage?,
               playTimeInSecs: Double, verbose: Int = 0) {
    let defaultPolicies = policyFn()
    precondition(defaultPolicies.count == 2)
    precondition(defaultPolicies[0].getName() != defaultPolicies[1].getName())

    let finalStats = PlayStats(policies: defaultPolicies, name: "final")

    let begin = Date().timeIntervalSince1970
    print("Start games at \(formatDate(timeIntervalSince1970: begin)).")
    print("Estimator playing time \(playTimeInSecs) secs.")

    let queue = DispatchQueue(label: "games", attributes: .concurrent)
    let group = DispatchGroup()

    let threads = verbose > 0 ? 1 : 8

    for i in 0 ..< threads {
        group.enter()
        queue.async {
            selfPlayAndRecord(currentBranch: i,
                              beginTime: begin,
                              gameFn: gameFn,
                              policyFn: policyFn,
                              finalStats: finalStats,
                              board: board,
                              storage: storage,
                              playTimeInSecs: playTimeInSecs,
                              verbose: verbose)
            group.leave()
            if verbose > 0 {
                print("Leaving thread \(i) at \(formatDate(timeIntervalSince1970: Date().timeIntervalSince1970)).")
            }
        }
    }
    group.wait()
    print("End games at \(formatDate(timeIntervalSince1970: Date().timeIntervalSince1970)).")
    finalStats.summarize()
}

fileprivate func selfPlayAndRecord(currentBranch i: Int,
                                   beginTime begin: Double,
                                   gameFn: @escaping () -> Game,
                                   policyFn: @escaping () -> [Policy],
                                   finalStats: PlayStats,
                                   board: Board,
                                   storage: CSVStorage?,
                                   playTimeInSecs: Double,
                                   verbose: Int) {
    // Policies are immutable.
    let policies = policyFn()
    let stats = PlayStats(policies: policies, name: "sub-branch-\(i)")

    var playRecords = Dictionary<Player, [PlayRecord]>()
    playRecords[.BLACK] = [PlayRecord]()
    playRecords[.WHITE] = [PlayRecord]()

    while true {
        // Stopping condition.
        let end = NSDate().timeIntervalSince1970 - begin
        if end >= playTimeInSecs {
            break
        }
        // Game is stateful. Creates a new game each time.
        let game = gameFn()

        let (blackPlayerPolicy, whitePlayerPolicy) = randomPermutation(policies: policies)
        let (winner, history) = selfPlayOneGame(game: game, board: board, blackPlayerPolicy: blackPlayerPolicy, whitePlayerPolicy: whitePlayerPolicy, verbose: verbose)
        stats.update(winner: winner, blackPlayerPolicy: blackPlayerPolicy, whitePlayerPolicy: whitePlayerPolicy)

        precondition(history.count == 2) // why?
        for k in history.keys {
            precondition(k == Player.WHITE || k == Player.BLACK)
        }

        if blackPlayerPolicy.shouldRecord() {
            let reward: Double
            if winner == nil {
                reward = 0.0
            } else {
                reward = winner == .BLACK ? 1.0 : -1.0
            }
            for item in history[.BLACK]! {
                playRecords[.BLACK]!.append(PlayRecord(history: item, reward: reward))
            }
        }

        if whitePlayerPolicy.shouldRecord() {
            let reward: Double
            if winner == nil {
                reward = 0.0
            } else {
                reward = winner == .WHITE ? 1.0 : -1.0
            }
            for item in history[.WHITE]! {
                playRecords[.WHITE]!.append(PlayRecord(history: item, reward: reward))
            }
        }
    }

    if verbose > 0 {
        print("Finish games ([\(i)]) at \(formatDate(timeIntervalSince1970: Date().timeIntervalSince1970)).")
    }

    finalStats.merge(stats)

    if storage != nil {
        // FIXME:
        var savedGames = 0
        for player in [Player.BLACK, Player.WHITE] {
            for record in playRecords[player]! {
                savedGames += 1
                storage!.save(state: record.history.state, nextPlayer: player,
                              legalMoves: record.history.legalMoves, distribution: record.history.unnormalizedProb,
                              reward: record.reward)
            }
        }
        if verbose > 0 {
            print("Finish recording ([\(i)]) at \(formatDate(timeIntervalSince1970: Date().timeIntervalSince1970)).")
        }
    }
}

// Play one game (stateless).
fileprivate func selfPlayOneGame(game: Game, board: Board, blackPlayerPolicy: Policy, whitePlayerPolicy: Policy,
                                 verbose: Int = 0) -> (Player?, Dictionary<Player, [PlayHistory]>) {
    var finalWinner: Player?
    var history = Dictionary<Player, [PlayHistory]>() // escape as return value
    history[.BLACK] = [PlayHistory]()
    history[.WHITE] = [PlayHistory]()

    while true {
        let stateHistory = game.stateHistory()
        let legalMoves = board.legalMoves(stateHistory: stateHistory)
        if legalMoves.isEmpty {
            if verbose > 0 {
                print("No legal moves. Tie")
            }
            break
        }

        let currentState = stateHistory.last!
        let nextPlayer = currentState.nextPlayer
        if verbose > 0 {
            print("Next player: \(nextPlayer)")
        }

        var move: Move
        var unnormalizedProb: [Double]
        if nextPlayer == .WHITE {
            (move, unnormalizedProb) = whitePlayerPolicy.getNextMove(stateHistory: stateHistory, legalMoves: legalMoves)
        } else {
            (move, unnormalizedProb) = blackPlayerPolicy.getNextMove(stateHistory: stateHistory, legalMoves: legalMoves)
        }

        let historyItem = PlayHistory(state: currentState, move: move, legalMoves: legalMoves, unnormalizedProb: unnormalizedProb)
        history[nextPlayer]!.append(historyItem)

        try! game.newMove(move)

        if verbose > 0 {
            print("Next move: \(move)")
            game.print()
        }
        if let winner = board.winner(stateHistory: game.stateHistory()) {
            if verbose > 0 {
                print("We have a winner \(winner)")
            }
            finalWinner = winner
            break
        }
    }

    assert(history.count >= 1) // Is this correct?
    return (finalWinner, history)
}