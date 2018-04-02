//
//  montecarlo.swift
//  five-in-a-row
//
//  Created by Jianwei Xie on 4/2/18.
//  Copyright © 2018 Jianwei Xie. All rights reserved.
//

import Foundation

class MonteCarlo {
  var boardSimulator: BoardSimulator
  var maxMoves: Int
  var calculationTime: Double
  
  init(boardSimulator: BoardSimulator, maxMoves: Int, calculationTime: Double) {
    self.boardSimulator = boardSimulator
    self.maxMoves = maxMoves
    self.calculationTime = calculationTime
  }
  
  func getNextMove(stateHistory: [State]) {
    let begin = NSDate().timeIntervalSince1970
    while NSDate().timeIntervalSince1970 - begin < self.calculationTime {
      runSimulation(stateHistory: stateHistory)
    }
  }
  
  func runSimulation(stateHistory: [State]) {
//    var stateHistoryCopy = stateHistory
//    var nextState = stateHistoryCopy.last!
//
//    for _ in 0..<self.maxMoves {
//      var legalMoves = boardSimulator.legalMoves(stateHistory: stateHistoryCopy)
//
//      let n = Int(arc4random_uniform(UInt32(legalMoves.count)))
//      let move = legalMoves[n]
//      let nextState = boardSimulator.nextState(state: nextState, move: move)
//      stateHistoryCopy.append(nextState)
//
//      if let winner = boardSimulator.winner(stateHistory: stateHistoryCopy) {
//        break
//      }
//    }
  }
}
