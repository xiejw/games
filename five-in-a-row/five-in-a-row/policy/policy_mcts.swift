import Foundation

class MCTSBasedPolicy: BasePolicy {
    private let size: Int
    private let perMoveSimulationTimes: Int
    private let predictor: Predictor
    private let board: Board
    private let playMode: Bool
    private let verbose: Int

    init(name: String, size: Int, predictor: Predictor, board: Board, perMoveSimulationTimes: Int,
         playMode: Bool = false, verbose: Int = 0) {
        self.size = size
        self.board = board
        self.perMoveSimulationTimes = perMoveSimulationTimes
        self.predictor = predictor
        self.playMode = playMode
        self.verbose = verbose
        super.init(name: name)
    }

    override func getNextMove(stateHistory: [State], legalMoves _: [Move], explore: Bool) -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
        let exploreMove = explore && !playMode
        return runSimulationsAndGetNextMove(originalStateHistory: stateHistory, explore: exploreMove)
    }

    private func runSimulationsAndGetNextMove(originalStateHistory: [State], explore: Bool) -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
        // We create a new cache each time and share between all simulations.
        let nodeFactory = NodeFactory(predictor: predictor, size: size, enforceExploreUnvisitedMoves: true)

        for i in 0 ..< perMoveSimulationTimes {
            if verbose > 0 && i % 1000 == 0 {
                print("Simulated \(i) times now.")
            }
            var visitedNodes = [Node]()
            var selectedMoves = [Move]()
            var blackPlayerReward: Double?

            // A new copy
            var stateHistory = originalStateHistory

            // Keep transvese until new node or game over. By that time, blackPlayerReward will be set.
            while true {
                let legalMoves = board.legalMoves(stateHistory: stateHistory)
                var lastState: State?

                if legalMoves.count == 0 {
                    blackPlayerReward = 0.0
                    break
                }

                lastState = stateHistory.last!
                let (node, nextPlayerReward) = nodeFactory.getNode(by: lastState!, legalMoves: legalMoves)

                if nextPlayerReward != nil {
                    let rewardFactor = lastState?.nextPlayer == .BLACK ? 1.0 : -1.0
                    blackPlayerReward = rewardFactor * nextPlayerReward!
                    break
                }

                let (_, move) = node.getNextMoveWithExploration()
                visitedNodes.append(node)
                selectedMoves.append(move)
                stateHistory.append(board.nextState(state: lastState!, move: move))
                if let winner = board.winner(stateHistory: stateHistory) {
                    blackPlayerReward = winner == .BLACK ? 1.0 : -1.0
                    break
                }
            }

            // Backup
            for (index, visitedNode) in visitedNodes.enumerated() {
                visitedNode.backup(blackPlayerReward: blackPlayerReward!, move: selectedMoves[index])
            }
        }

        if !explore {
            return nodeFactory.getRootNode(originalStateHistory.last!).getBestMoveForPlay(verbose: verbose)
        } else {
            return nodeFactory.getRootNode(originalStateHistory.last!).getBestMove()
        }
    }
}
