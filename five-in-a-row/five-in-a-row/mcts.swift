import Foundation

protocol MCTSAlgorithm {
  func selfPlay(stateHistory: [State], calculationTime: Double)
  func getNextMove(stateHistory: [State], calculationTime: Double) -> Move?
}

struct SimuationStats {
  var blackWins: Int
  var whiteWins: Int
  var games: Int
  var startTime: Double
  var endTime: Double
}
