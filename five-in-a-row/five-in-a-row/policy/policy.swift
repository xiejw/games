// Defines Policy to find the next Move.
import Foundation

protocol Policy {
    func getName() -> String
    func shouldRecord() -> Bool

    // policyDistribution[i] is the unnormalized distribution for move legalMoves[i]
    func getNextMove(stateHistory: [State], legalMoves: [Move]) -> (nextMove: Move, policyUnnormalizedDistribution: [Double])
}

class BasePolicy: Policy {
    let name: String
    let record: Bool

    init(name: String, shouldRecord: Bool) {
        self.name = name
        record = shouldRecord
    }

    func getName() -> String {
        return name
    }

    func shouldRecord() -> Bool {
        return record
    }

    func getNextMove(stateHistory _: [State], legalMoves _: [Move]) -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
        preconditionFailure("Not implemented.")
    }
}

class RandomPolicy: BasePolicy {
    init(name: String = "Random") {
        super.init(name: name, shouldRecord: false)
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
