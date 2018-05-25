import Foundation

let configuration: Configuration

if let value = ProcessInfo.processInfo.environment["RL_TIME_IN_SECS"] {
    print("RL mode.")
    configuration = Configuration(selfPlayTimeInSecs: Double(value)!, recordStates: true)
    print("Configuration:\n\(configuration)")
    selfPlaysAndRecord(size: configuration.size,
                       numberToWin: configuration.numberToWin,
                       selfPlayTimeInSecs: configuration.selfPlayTimeInSecs!,
                       perMoveSimulationTimes: configuration.perMoveSimulationTimes,
                       recordStates: configuration.recordStates,
                       verbose: configuration.verbose)
    exit(0)
}

if let value = ProcessInfo.processInfo.environment["RATING_TIME_IN_SECS"] {
    print("Rating mode.")
    let selfPlayTimeInSecs = Double(value)!

    if let policyName = ProcessInfo.processInfo.environment["POLICY_NAME"] {
        print("Rating mode. Policy name \(policyName)")
        configuration = Configuration(selfPlayTimeInSecs: selfPlayTimeInSecs,
                                      ratingStage: true)
        print("Configuration:\n\(configuration)")
        let board = Board(size: configuration.size,
                          numberToWin: configuration.numberToWin)
        func policyFn() -> [Policy] {
            precondition(policyName != "mcts")
            let mctsPolicy = MCTSBasedPolicy(name: "mcts", size: configuration.size,
                                             predictor: DistributionPredictionWrapper(size: configuration.size),
                                             board: board,
                                             perMoveSimulationTimes: configuration.perMoveSimulationTimes)
            let otherPolicy = MCTSBasedPolicy(name: policyName,
                                              size: configuration.size,
                                              predictor: DistributionPredictionForLastIterationWrapper(
                                                  size: configuration.size),
                                              board: board,
                                              perMoveSimulationTimes: configuration.perMoveSimulationTimes)
            return [mctsPolicy, otherPolicy]
        }
        _ = selfPlaysAndRating(size: configuration.size,
                               numberToWin: configuration.numberToWin,
                               policyFn: policyFn,
                               selfPlayTimeInSecs: configuration.selfPlayTimeInSecs!,
                               perMoveSimulationTimes: configuration.perMoveSimulationTimes,
                               verbose: configuration.verbose)

    } else {
        print("Rating mode. Premade policis.")
        configuration = Configuration(ratingStage: true)

        print("Configuration:\n\(configuration)")
        let policyFn = getPremadePolicisToRating(size: configuration.size,
                                                 numberToWin: configuration.numberToWin,
                                                 board: Board(size: configuration.size,
                                                              numberToWin: configuration.numberToWin),
                                                 perMoveSimulationTimes: configuration.perMoveSimulationTimes)

        let playStats = selfPlaysAndRating(size: configuration.size,
                                           numberToWin: configuration.numberToWin,
                                           policyFn: policyFn,
                                           selfPlayTimeInSecs: selfPlayTimeInSecs,
                                           perMoveSimulationTimes: configuration.perMoveSimulationTimes,
                                           verbose: configuration.verbose)

        let winningRate = playStats.getWinningRate(policyName: "mcts")
        let logger = Logger()
        if winningRate > 0.55 {
            logger.logAndPrint("Good checkpoint: \(winningRate)")
            exit(0)
        } else {
            logger.logAndPrint("Bad checkpoint: \(winningRate)")
            exit(123)
        }
    }
    exit(0)
}

configuration = Configuration(perMoveSimulationTimes: 10000, vsHuman: true, verbose: 1)
print("Configuration:\n\(configuration)")
// Play with human
playWithHuman(size: configuration.size,
              numberToWin: configuration.numberToWin,
              perMoveSimulationTimes: configuration.perMoveSimulationTimes,
              verbose: configuration.verbose)
