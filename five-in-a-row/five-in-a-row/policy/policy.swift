// Defines Policy to find the next Move.
import Foundation

protocol Policy {
    func getName() -> String

    // policyDistribution[i] is the unnormalized distribution for move legalMoves[i]
    func getNextMove(stateHistory: [State], legalMoves: [Move]) -> (nextMove: Move, policyUnnormalizedDistribution: [Double])
}

class BasePolicy: Policy {
    let name: String

    init(name: String) {
        self.name = name
    }

    func getName() -> String {
        return name
    }

    func getNextMove(stateHistory _: [State], legalMoves _: [Move]) -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
        preconditionFailure("Not implemented.")
    }
}

class RandomPolicy: BasePolicy {
    override init(name: String = "Random") {
        super.init(name: name)
    }

    override func getNextMove(stateHistory _: [State], legalMoves: [Move]) -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
        var policyDistribution = [Double]()
        let prob = 1.0
        for _ in 0 ..< legalMoves.count {
            policyDistribution.append(prob)
        }
        return (randomMove(moves: legalMoves), policyDistribution)
    }
}
