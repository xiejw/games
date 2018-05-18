import Foundation

class MCTSBasedPolicy: Policy {
    let name: String
    let size: Int
    let perMoveSimulationTimes: Int
    let predictor: Predictor
    let board: Board
    let record: Bool
    let playMode: Bool
    let verbose: Int

    init(name: String, size: Int, predictor: Predictor, board: Board, perMoveSimulationTimes: Int,
         shouldRecord: Bool = true, playMode: Bool = false, verbose: Int = 0) {
        self.name = name
        self.size = size
        self.board = board
        self.perMoveSimulationTimes = perMoveSimulationTimes
        self.predictor = predictor
        record = shouldRecord
        self.playMode = playMode
        self.verbose = verbose
    }

    func getName() -> String {
        return name
    }

    func shouldRecord() -> Bool {
        return record
    }

    func getNextMove(stateHistory: [State], legalMoves _: [Move]) -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
        return runSimulationsAndGetNextMove(originalStateHistory: stateHistory)
    }

    private func runSimulationsAndGetNextMove(originalStateHistory: [State]) -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
        // We create a new cache each time and share between all simulations.
        let nodeFactory = NodeFactory(predictor: predictor, size: size)

        for i in 0 ..< perMoveSimulationTimes {
            if verbose > 0 && i % 100 == 0 {
                print("Simulated \(i) times now.")
            }
            var visitedNodes = [Node]()
            var selectedMoves = [Move]()
            // A new copy
            var stateHistory = originalStateHistory
            // Keep transvese until new node.
            while true {
                let legalMoves = board.legalMoves(stateHistory: stateHistory)
                var reward: Double?
                var node: Node?
                var nextState: State?

                if legalMoves.count == 0 {
                    reward = 0.0
                } else {
                    nextState = stateHistory.last!
                    var tmpNode: Node
                    (tmpNode, reward) = nodeFactory.getNextNode(state: nextState!, legalMoves: legalMoves)
                    node = tmpNode
                }

                if reward != nil {
                    for (index, visitedNode) in visitedNodes.enumerated() {
                        visitedNode.backup(reward!, move: selectedMoves[index])
                    }
                    break
                }
                let (_, move) = node!.getNextMoveWithExploration()
                visitedNodes.append(node!)
                selectedMoves.append(move)
                stateHistory.append(board.nextState(state: nextState!, move: move))
            }
        }

        if playMode {
            return nodeFactory.getRootNode(originalStateHistory.last!).getBestMove()
        } else {
            return nodeFactory.getRootNode(originalStateHistory.last!).getBestMoveForPlay()
        }
    }
}
