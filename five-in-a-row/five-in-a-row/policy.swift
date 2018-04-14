// Defines Policy to find the next Move.
import Foundation

protocol Policy {
  func getName() -> String
  func getNextMove(stateHistory: [State], legalMoves: [Move]) -> Move
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
}

fileprivate func randomMove(moves: [Move]) -> Move {
  let n = Int(arc4random_uniform(UInt32(moves.count)))
  return moves[n]
}
