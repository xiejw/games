import Foundation

class Node {
    private var qValueTotal = Dictionary<Move, Double>()
    private var visitCount = Dictionary<Move, Int>()
    private var prioryProbability = Dictionary<Move, Double>()

    let legalMoves: [Move]
    var totalCount = 0.0

    init(nonNormalizedProbability: [Double], legalMoves: [Move], size: Int) {
        self.legalMoves = legalMoves
        var probabilityForLegalMoves = [Double]()
        var sum = 0.0
        for move in legalMoves {
            // C-style array
            let prob = nonNormalizedProbability[move.x * size + move.y]
            probabilityForLegalMoves.append(prob)
            sum += prob
        }

        for (index, move) in legalMoves.enumerated() {
            prioryProbability[move] = probabilityForLegalMoves[index] / sum
            visitCount[move] = 0
            qValueTotal[move] = 0.0
        }
    }

    func getNextMoveWithExploration() -> (Double, Move) {
        var bestValue = -100.0
        var bestMove: Move?
        // FIXME: unvisjted nodes
        for (move, p) in prioryProbability {
            let count = visitCount[move]!
            // FIXME:
            var value = 1.0 * p * (1.0 + sqrt(totalCount)) / (1.0 + Double(count))
            if count > 0 {
                // Void edge case.
                value += qValueTotal[move]! / Double(count)
            }
            if value > bestValue {
                bestValue = value
                bestMove = move
            }
        }

        return (bestValue, bestMove!)
    }

    func backup(_ reward: Double, move: Move) {
        qValueTotal[move]! += reward
        visitCount[move]! += 1
        totalCount += 1
    }

    func getBestMove() -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
        var probabilities = [Double]()
        for move in legalMoves {
            probabilities.append(Double(visitCount[move]!))
        }
        let index = sampleFromProbabilities(probabilities: probabilities)
        return (legalMoves[index], probabilities)
    }

    func getBestMoveForPlay() -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
        var probabilities = [Double]()
        var bestMove: Move?
        var bestCount = 0
        for move in legalMoves {
            let count = visitCount[move]!
            probabilities.append(Double(count))
            if count > bestCount {
                bestCount = visitCount[move]!
                bestMove = move
            }
        }
        return (bestMove!, probabilities)
    }
}

class NodeFactory {
    private var nodePool = Dictionary<State, Node>()
    private let predictor: Predictor
    private let size: Int

    init(predictor: Predictor, size: Int) {
        self.predictor = predictor
        self.size = size
    }

    // Returns a Node in MCTS explore with its reward. If reward is nil, the node has been visited before.
    func getNextNode(state: State, legalMoves: [Move]) -> (node: Node, reward: Double?) {
        if let node = nodePool[state] {
            return (node, nil)
        }

        let nextPlayer = state.nextPlayer
        let (probability, reward) = predictor.predictDistributionAndReward(
            state: state, nextPlayer: nextPlayer)
        let node = Node(nonNormalizedProbability: probability, legalMoves: legalMoves, size: size)
        nodePool[state] = node
        return (node, reward)
    }

    func getRootNode(_ state: State) -> Node {
        return nodePool[state]!
    }
}
