import Foundation

struct SimuationStats {
  var blackWins: Int
  var whiteWins: Int
  var games: Int
  var startTime: Double
  var endTime: Double
}

class MonteCarlo {
  
  var gameSimulator: GameSimulator
  var maxMoves: Int
  var calculationTime: Double
  var randomOnly: Bool
  var storage: Storage?
  
  var plays = Dictionary<State, Int>()
  var blackWins = Dictionary<State, Int>()
  var whiteWins = Dictionary<State, Int>()
  
  init(gameSimulator: GameSimulator, maxMoves: Int, calculationTime: Double,
       randomOnly: Bool = true, storage: Storage? = nil) {
    self.gameSimulator = gameSimulator
    self.maxMoves = maxMoves
    self.calculationTime = calculationTime
    self.randomOnly = randomOnly
    self.storage = storage
  }
  
  fileprivate func printLearningStats(_ simulationStats: SimuationStats) {
    print("Played \(simulationStats.games) games with search depth \(self.maxMoves).")
    let blackWinsRatio = Double(simulationStats.blackWins) * 1.0 / Double(simulationStats.games)
    let whiteWinsRatio = Double(simulationStats.whiteWins) * 1.0 / Double(simulationStats.games)
    print("BlackWins: \(simulationStats.blackWins) -- \(blackWinsRatio)")
    print("WhiteWins: \(simulationStats.whiteWins) -- \(whiteWinsRatio)")
    print("Total plays in memory \(self.plays.count)")
    print("Updated plays in memory \(self.updatedState)")
    print("Reused plays in memory \(self.reuseState)")
    print("Random moves \(self.randomMoves)")
    print("UCB moves \(self.ucbMoves) -- \(Double(self.ucbMoves) / Double(randomMoves + ucbMoves))")
  }
  
  func warmUp(stateHistory: [State], warmupTime: Double) {
    let simulationStats = runSimulations(stateHistory: stateHistory,
                                         calculationTime: warmupTime)
    
    // Print out the statistic.
    printLearningStats(simulationStats)
  }
  
  func getNextMove(stateHistory: [State]) -> Move? {
    let simulationStats = runSimulations(stateHistory: stateHistory,
                                         calculationTime: self.calculationTime)
    
    // Print out the statistic.
    printLearningStats(simulationStats)
    
    // Find the best move.
    let currentState = stateHistory.last!
    let legalMoves = gameSimulator.legalMoves(stateHistory: stateHistory)
    let nextPlayer = currentState.nextPlayer
    let winsTable = nextPlayer == .BLACK ? blackWins : whiteWins
    
    var maxWins = 0.0
    var bestMove: Move? = nil
    var moveResult = Dictionary<Move, Double>()
    
    for move in legalMoves {
      let nextState = gameSimulator.nextState(state: currentState, move: move)
      if let games = self.plays[nextState]  {
        let wins = Double(winsTable[nextState]!) / Double(games)
        moveResult[move] = wins
        
        if wins > maxWins {
          maxWins = wins
          bestMove = move
        }
      }
    }
    
    if maxWins == 0 {
      print("No stats.")
    } else {
      print("bestMove \(bestMove!)")
      print("All results: ")
      let sortedResult = moveResult.sorted{ $0.value > $1.value }
      for result in sortedResult[0..<5] {
        print(" -> \(result.1): \(result.0)")
      }
    }
    
    return bestMove
  }
  
  fileprivate func formatDate(_ timeIntervalSince1970: Double) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone.current
    
    return dateFormatter.string(from: Date(timeIntervalSince1970: timeIntervalSince1970))
  }
  
  // Run multiple simulations within a time constraint.
  fileprivate func runSimulations(stateHistory: [State], calculationTime: Double) -> SimuationStats {
    let begin = Date().timeIntervalSince1970
    var games = 0
    var blackWins = 0
    var whiteWins = 0

    print("Start simulation at \(formatDate(begin)).")
    print("Estimator calculation time \(calculationTime) secs.")
    var end = NSDate().timeIntervalSince1970 - begin
    while  end < calculationTime {
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
  
  // Run one simulation and return the possible winner.
  fileprivate func runSimulation(stateHistory: [State]) -> Player? {
    var stateHistoryCopy = stateHistory
    var nextState = stateHistoryCopy.last!
    var visitedSates = Set<State>()
    
    var finalWinner: Player? = nil
    var expand = true
    
    for _ in 0..<self.maxMoves {
      let legalMoves = gameSimulator.legalMoves(stateHistory: stateHistoryCopy)
      
      if legalMoves.isEmpty {
        break
      }
      
      // Choose a move.
      let move = chooseAMove(legalMoves: legalMoves, stateHistory: stateHistoryCopy)
      nextState = gameSimulator.nextState(state: nextState, move: move)
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
      
      if let winner = gameSimulator.winner(stateHistory: stateHistoryCopy) {
        finalWinner = winner
        break
      }
    }
    
    // Update status.
    for state in visitedSates {
      if let games = self.plays[state]  {
        
        self.updatedState += 1
        if games > 0 {
          self.reuseState += 1
        }

        self.plays[state]! += 1
        
        if storage != nil {
          storage?.save(state: state, winner: finalWinner)
        }
        
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
  
  // Choose a Move from legalMoves and stateHistory.
  fileprivate func chooseAMove(legalMoves: [Move], stateHistory: [State]) -> Move {
    func pickARandomMove() -> Move {
#if os(Linux)
      // This has a module bias.
      let n = Int(random() % legalMoves.count)
#else
      let n = Int(arc4random_uniform(UInt32(legalMoves.count)))
#endif
      self.randomMoves += 1
      return legalMoves[n]
    }
    
    if self.randomOnly || legalMoves.count == 0 {
      return pickARandomMove()
    }
    
    var hasAllKnowledge = true
    let currentState = stateHistory.last!
    let nextPlayer = currentState.nextPlayer
    
    var states = [State]()
    var totalPlays = 0
    for move in legalMoves {
      let nextState = gameSimulator.nextState(state: currentState, move: move)
      states.append(nextState)
      if let games = self.plays[nextState] {
        totalPlays += games
      } else {
        hasAllKnowledge = false
        break
      }
    }
    
    if !hasAllKnowledge {
      return pickARandomMove()
    }
    
    // Now use UCB1.
    var winsTable = nextPlayer == .BLACK ? blackWins : whiteWins
    let logOfTotalGames = log(Double(totalPlays))
    var bestMove: Move? = nil
    var bestPlayOut = 0.0
    for (index, move) in legalMoves.enumerated() {
      let nextState = states[index]
      let gamses = Double(self.plays[nextState]!)
      
      var playOut = Double(winsTable[nextState]!) / gamses
      playOut += 1.4 * sqrt(logOfTotalGames / gamses)
      
      if playOut > bestPlayOut {
        bestPlayOut = playOut
        bestMove = move
      }
    }
    self.ucbMoves += 1
    return bestMove!
  }
  
  // remove me.
  var updatedState = 0
  var reuseState = 0
  var randomMoves = 0
  var ucbMoves = 0
}
