// NEED Examine.
// Defines Policy to find the next Move.
import Foundation

protocol Policy {
    func getName() -> String
    // policyDistribution[i] is the unnormalized distribution for move legalMoves[i]
    func getNextMove(stateHistory: [State], legalMoves: [Move]) -> (nextMove: Move, policyUnnormalizedDistribution: [Double])
    func shouldRecord() -> Bool
}

class RandomPolicy: Policy {
    let name: String

    init(name: String = "Random") {
        self.name = name
    }

    func getName() -> String {
        return name
    }

    func getNextMove(stateHistory _: [State], legalMoves: [Move]) -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
        var policyDistribution = [Double]()
        let prob = 1.0
        for _ in 0 ..< legalMoves.count {
            policyDistribution.append(prob)
        }
        return (randomMove(moves: legalMoves), policyDistribution)
    }

    func shouldRecord() -> Bool {
        return false
    }
}

//
// class DistributionBasedPolicy: Policy {
//    let name: String
//    let size: Int
//    let distributionGenerator: DistributionPredictionWrapper
//    let record: Bool
//
//    init(name: String, size: Int, distributionGenerator: DistributionPredictionWrapper, shouldRecord: Bool = true) {
//        self.name = name
//        self.size = size
//        self.distributionGenerator = distributionGenerator
//        record = shouldRecord
//    }
//
//    func getName() -> String {
//        return name
//    }
//
//    func shouldRecord() -> Bool {
//        return record
//    }
//
//    func getNextMove(stateHistory: [State], legalMoves: [Move]) -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
//        let lastState = stateHistory.last!
//        let nextPlayer = lastState.nextPlayer
//        let (probabilities, _) = distributionGenerator.predictDistributionAndReward(state: lastState, nextPlayer: nextPlayer)
//
//        var validflattenIndices = [Int]()
//        var legalProbs = [Double]()
//        for move in legalMoves {
//            let flattenIndex = move.x * size + move.y
//            validflattenIndices.append(flattenIndex)
//            legalProbs.append(probabilities[flattenIndex])
//        }
//
//        let sampleFlattenIndex = sampleFromProbabilities(probabilities: legalProbs)
//        let flattenIndex = validflattenIndices[sampleFlattenIndex]
//        return (Move(x: flattenIndex / size, y: flattenIndex % size), legalProbs)
//    }
// }
