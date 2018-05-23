import Foundation

func getPremadePolicisToRating(size: Int, numberToWin: Int, board: Board, perMoveSimulationTimes: Int,  verbose: Int = 0) -> [() -> [Policy]] {
    
    func policyFn1() -> [Policy] {
        let mctsPolicy = MCTSBasedPolicy(name: "mcts", size: size,
                                         predictor: DistributionPredictionWrapper(size: size),
                                         board: board, perMoveSimulationTimes: perMoveSimulationTimes)
        let randomPolicy = RandomPolicy(name: "random")
        return [mctsPolicy, randomPolicy]
    }
    
    func policyFn2() -> [Policy] {
        let mctsPolicy = MCTSBasedPolicy(name: "mcts", size: size,
                                         predictor: DistributionPredictionWrapper(size: size),
                                         board: board, perMoveSimulationTimes: perMoveSimulationTimes)
        let randomPredictorPolicy = MCTSBasedPolicy(name: "mcts_random_predictor", size: size,
                                                    predictor: RandomPredictor(size: size),
                                                    board: board, perMoveSimulationTimes: perMoveSimulationTimes)
        return [mctsPolicy, randomPredictorPolicy]
    }
    
    func policyFn3() -> [Policy] {
        let mctsPolicy = MCTSBasedPolicy(name: "mcts", size: size,
                                         predictor: DistributionPredictionWrapper(size: size),
                                         board: board, perMoveSimulationTimes: perMoveSimulationTimes)
        let mctsLastIterationPolicy = MCTSBasedPolicy(name: "mcts_last_iteration", size: size,
                                                      predictor: DistributionPredictionForLastIterationWrapper(size: size),
                                                      board: board, perMoveSimulationTimes: perMoveSimulationTimes)
        return [mctsPolicy, mctsLastIterationPolicy]
    }
    
    return [policyFn1, policyFn2, policyFn3]
}
