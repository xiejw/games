// Defines Policy to find the next Move.
import Foundation

protocol Policy {
  func getName() -> String
  func getNextMove(stateHistory: [State], legalMoves: [Move]) -> Move
  func shouldRecord() -> Bool
}

class RandomPolicy: Policy {
  
  let name: String
  
  init(name: String) {
    self.name = name
  }
  
  func getName() -> String {
    return name
  }
  
  func getNextMove(stateHistory: [State], legalMoves: [Move]) -> Move {
    return randomMove(moves: legalMoves)
  }
  
  func shouldRecord() -> Bool {
    return false
  }
}

class DistributionBasedPolicy: Policy {
  
  let name: String
  let size: Int
  let distributionGenerator: DistributionPredictionWrapper
  let record: Bool
  
  init(name: String, size: Int, distributionGenerator: DistributionPredictionWrapper, shouldRecord: Bool = true) {
    self.name = name
    self.size = size
    self.distributionGenerator = distributionGenerator
    self.record = shouldRecord
  }
  
  func getName() -> String {
    return name
  }
  
  func shouldRecord() -> Bool {
    return record
  }
  
  func getNextMove(stateHistory: [State], legalMoves: [Move]) -> Move {
    let lastState = stateHistory.last!
    let nextPlayer = lastState.nextPlayer
    let (probabilities, _) = distributionGenerator.predictDistributionAndReward(state: lastState, nextPlayer: nextPlayer)
    
    var validflattenIndices = [Int]()
    var legalProbs = [Double]()
    for move in legalMoves {
      let flattenIndex = move.x * size + move.y
      validflattenIndices.append(flattenIndex)
      legalProbs.append(probabilities[flattenIndex])
    }
    
    let sampleFlattenIndex = sampleFromProbabilities(probabilities: legalProbs)
    let flattenIndex = validflattenIndices[sampleFlattenIndex]
    return Move(x: flattenIndex / size, y: flattenIndex % size)
  }
}


fileprivate func sampleFromProbabilities(probabilities: [Double]) -> Int {
  var pmf = [Double]()
  var currentSum = 0.0
  for prob in probabilities {
    currentSum += prob
    pmf.append(currentSum)
  }
  
  let sampleSpace: UInt32 = 10000
  let sample = Int(arc4random_uniform(sampleSpace))
  
  for i in 0..<probabilities.count {
    if Double(sample) / Double(sampleSpace) * currentSum < pmf[i] {
      return i
    }
  }
  return probabilities.count - 1
}

fileprivate func randomMove(moves: [Move]) -> Move {
  let n = Int(arc4random_uniform(UInt32(moves.count)))
  return moves[n]
}
