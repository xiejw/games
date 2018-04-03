//
//  montecarlo.swift
//  five-in-a-row
//
//  Created by Jianwei Xie on 4/2/18.
//  Copyright © 2018 Jianwei Xie. All rights reserved.
//

import Foundation

struct SimuationStats {
  var blackWins: Int
  var whiteWins: Int
  var games: Int
  var startTime: Double
  var endTime: Double
}

class MonteCarlo {
  
  var boardSimulator: BoardSimulator
  var maxMoves: Int
  var calculationTime: Double
  var plays = Dictionary<State, Int>()
  var blackWins = Dictionary<State, Int>()
  var whiteWins = Dictionary<State, Int>()
  
  init(boardSimulator: BoardSimulator, maxMoves: Int, calculationTime: Double) {
    self.boardSimulator = boardSimulator
    self.maxMoves = maxMoves
    self.calculationTime = calculationTime
  }
  
  func getNextMove(stateHistory: [State]) {
    let simulationStats = runSimulations(stateHistory: stateHistory)
    
    print("Played \(simulationStats.games) games with search depth \(self.maxMoves).")
    let blackWinsRatio = Double(simulationStats.blackWins) * 1.0 / Double(simulationStats.games)
    let whiteWinsRatio = Double(simulationStats.whiteWins) * 1.0 / Double(simulationStats.games)
    print("BlackWins: \(simulationStats.blackWins) -- \(blackWinsRatio)")
    print("WhiteWins: \(simulationStats.whiteWins) -- \(whiteWinsRatio)")

    // var legalMoves = boardSimulator.legalMoves(stateHistory: stateHistory)
    // var nextPlayer = boardSimulator.nextPlayer(state: stateHistory.last!)
    
  }
  
  func runSimulations(stateHistory: [State]) -> SimuationStats {
    let begin = NSDate().timeIntervalSince1970
    var games = 0
    var blackWins = 0
    var whiteWins = 0
    
    print("Start simulation at \(begin)")
    var end = NSDate().timeIntervalSince1970 - begin
    while  end < self.calculationTime {
      if let player = runSimulation(stateHistory: stateHistory) {
        if player == .BLACK {
          blackWins += 1
        } else {
          whiteWins += 1
        }
      }
      games += 1
      end = NSDate().timeIntervalSince1970 - begin
    }
    print("End simulation at \(end)")

    return SimuationStats(blackWins: blackWins, whiteWins: whiteWins,
                          games: games, startTime: begin, endTime: end)
  }
  
  func runSimulation(stateHistory: [State]) -> Player? {
    var stateHistoryCopy = stateHistory
    var nextState = stateHistoryCopy.last!
    var visitedSates = Set<State>()
    
    var finalWinner: Player? = nil
    var expand = true
    
    for _ in 0..<self.maxMoves {
      var legalMoves = boardSimulator.legalMoves(stateHistory: stateHistoryCopy)
      
      let n = Int(arc4random_uniform(UInt32(legalMoves.count)))
      let move = legalMoves[n]
      nextState = boardSimulator.nextState(state: nextState, move: move)
      stateHistoryCopy.append(nextState)
      
      visitedSates.insert(nextState)
      if expand {
        if self.plays[nextState] == nil {
          // Only expand once.
          expand = false
          self.plays[nextState] = 0
          self.blackWins[nextState] = 0
          self.whiteWins[nextState] = 0
        }
      }
      
      if let winner = boardSimulator.winner(stateHistory: stateHistoryCopy) {
        finalWinner = winner
        break
      }
    }
    
    // Update status.
    for state in visitedSates {
      if self.plays[state] != nil {
        self.plays[state]! += 1
        
        if finalWinner != nil {
          if finalWinner! == .BLACK {
            self.blackWins[state]! += 1
          } else {
            self.whiteWins[state]! += 1
          }
        }
      }
    }
    return finalWinner
  }
}
