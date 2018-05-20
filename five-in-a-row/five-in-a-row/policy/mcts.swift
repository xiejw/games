import Foundation

class Node {
    static let unvisitedMoveValue = 999.0

    var qValueTotal = Dictionary<Move, Double>()
    var visitCount = Dictionary<Move, Int>()
    var prioryProbability = Dictionary<Move, Double>()

    private let nextPlayer: Player
    private let legalMoves: [Move]
    private var totalCount = 0.0
    private let enforceExploreUnvisitedMoves: Bool

    init(nextPlayer: Player, nonNormalizedProbability: [Double], legalMoves: [Move], size: Int,
         enforceExploreUnvisitedMoves: Bool) {
        self.nextPlayer = nextPlayer
        self.legalMoves = legalMoves
        self.enforceExploreUnvisitedMoves = enforceExploreUnvisitedMoves

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
        var unvisitedMoves: [Move]?

        if enforceExploreUnvisitedMoves {
            unvisitedMoves = [Move]()
        }
        for (move, p) in prioryProbability {
            let count = visitCount[move]!

            if enforceExploreUnvisitedMoves && count == 0 {
                unvisitedMoves!.append(move)
            }

            var value = 1.0 * p * (1.0 + sqrt(totalCount)) / (1.0 + Double(count))
            if count > 0 {
                // Void edge case.
                value += qValueTotal[move]! / Double(count)
            }
            if value > bestValue { // Consider to break the tie.
                bestValue = value
                bestMove = move
            }
        }

        if enforceExploreUnvisitedMoves && unvisitedMoves!.count > 0 {
            return (Node.unvisitedMoveValue, randomMove(moves: unvisitedMoves!))
        }

        return (bestValue, bestMove!)
    }

    func backup(blackPlayerReward: Double, move: Move) {
        var reward = blackPlayerReward
        if nextPlayer == .WHITE {
            reward *= -1.0 // Zero sum.
        }

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

    func getBestMoveForPlay(verbose: Int = 0) -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
        var probabilities = [Double]()
        var bestMove: Move?
        var bestCount = 0
        var moveStats: Dictionary<Move, Double>?
        if verbose > 0 {
            moveStats = Dictionary<Move, Double>()
        }
        for move in legalMoves {
            let count = visitCount[move]!
            probabilities.append(Double(count))
            if verbose > 0 {
                moveStats![move] = Double(count)
            }
            if count > bestCount {
                bestCount = visitCount[move]!
                bestMove = move
            }
        }
        if verbose > 0 {
            var printCount = 0
            for (move, prob) in (moveStats!.sorted { $0.1 > $1.1 }) {
                printCount += 1
                if printCount > 5 {
                    break
                }
                print(" Candidate \(move): \(prob) -- qValue \(qValueTotal[move]! / Double(visitCount[move]!))")
            }
        }
        return (bestMove!, probabilities)
    }
}

class NodeFactory {
    private var nodePool = Dictionary<State, Node>()
    private let predictor: Predictor
    private let size: Int
    private let enforceExploreUnvisitedMoves: Bool

    init(predictor: Predictor, size: Int, enforceExploreUnvisitedMoves: Bool = false) {
        self.predictor = predictor
        self.size = size
        self.enforceExploreUnvisitedMoves = enforceExploreUnvisitedMoves
    }

    // Returns a Node in MCTS explore with its reward. If reward is nil, the node has been visited before.
    func getNode(by state: State, legalMoves: [Move]) -> (node: Node, nextPlayerReward: Double?) {
        if let node = nodePool[state] {
            return (node, nil) // Returns from cache.
        }

        let (probability, nextPlayerReward) = predictor.predictDistributionAndNextPlayerReward(state: state)
        let node = Node(nextPlayer: state.nextPlayer, nonNormalizedProbability: probability, legalMoves: legalMoves, size: size,
                        enforceExploreUnvisitedMoves: enforceExploreUnvisitedMoves)
        nodePool[state] = node
        return (node, nextPlayerReward)
    }

    func getRootNode(_ state: State) -> Node {
        return nodePool[state]!
    }
}
