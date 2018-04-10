import Foundation

fileprivate class MCTSNode {
  
  var state: State
  var hasLearned: Bool = false
  var basePrioriGames: Int
  
  var games: Int
  var rewards: Double
  var realGames: Int {
    get {
      return games
    }
  }
  
  init(state: State, baseBlackWinningProbability: Double, basePrioriGames: Int) {
    self.state = state
    self.basePrioriGames = basePrioriGames

    self.rewards = baseBlackWinningProbability * Double(basePrioriGames)
    self.games = basePrioriGames
  }
  
  func isNewNode() -> Bool {
    return !hasLearned
  }
  
  func blackWinningProbability() -> Double {
    return rewards / Double(games)
  }
  
  func learn(blackWinningReward: Double) {
    hasLearned = true
    games += 1
    rewards += blackWinningReward
  }
}

fileprivate class MCTSNodeFactory {
  
  var nodePools = Dictionary<State, MCTSNode>()
  let predictor: StatePredictionWrapper
  let basePriorGames = 3
  
  init(predictor: StatePredictionWrapper) {
    self.predictor = predictor
  }
  
  func getNode(state: State) -> MCTSNode {
    if let node = nodePools[state] {
      return node
    } else {
      let baseBlackWinningProbability = predictor.predictBlackPlayerWinning(state: state)
      let newNode = MCTSNode(state: state,
                             baseBlackWinningProbability: baseBlackWinningProbability,
                             basePrioriGames: basePriorGames)
      nodePools[state] = newNode
      return newNode
    }
  }
  
  func saveNodes(storage: Storage) {
    for (state, node) in nodePools {
      if !node.isNewNode() {
        storage.save(state: state, blackWinnerProbability: node.blackWinningProbability())
      }
    }
  }
}

class ImprovedMCTS: MCTSAlgorithm {
  
  var gameSimulator: GameSimulator
  var storage: Storage?
  
  var numUpdatedNodes = 0
  fileprivate let nodeFactory: MCTSNodeFactory

  init(gameSimulator: GameSimulator, storage: Storage? = nil) {
    self.gameSimulator = gameSimulator
    let predictor = StatePredictionWrapper(size: gameSimulator.size)
    nodeFactory = MCTSNodeFactory(predictor: predictor)
    self.storage = storage
  }
  
  func selfPlay(stateHistory: [State], calculationTime: Double) {
    let simulationStats = runSimulations(stateHistory: stateHistory,
                                         calculationTime: calculationTime)
    print(simulationStats)
    if storage != nil {
      nodeFactory.saveNodes(storage: storage!)
    }
  }
  
  func getNextMove(stateHistory: [State], calculationTime: Double) -> Move? {
    let simulationStats = runSimulations(stateHistory: stateHistory,
                                         calculationTime: calculationTime)

    
    // Find the best move.
    let legalMoves = gameSimulator.legalMoves(stateHistory: stateHistory)
    let move = chooseAMove(explore: false, legalMoves: legalMoves, stateHistory: stateHistory)
    
    print(simulationStats)
    return move
  }
  
  // Run multiple simulations within a time constraint.
  fileprivate func runSimulations(stateHistory: [State], calculationTime: Double) -> SimuationStats {
    numUpdatedNodes = 0
    
    let begin = Date().timeIntervalSince1970
    var games = 0
    var blackWins = 0
    var whiteWins = 0

    print("Start simulation at \(formatDate(timeIntervalSince1970: begin)).")
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
    print("Num of Updates \(numUpdatedNodes)")
    print("Nonexplore moves \(self.nonExploreTimes)")
    print("Explore moves \(self.exploreTimes)")
    
    return SimuationStats(blackWins: blackWins,
                          whiteWins: whiteWins,
                          games: games,
                          startTime: begin,
                          endTime: end)
  }
  
  // Run one simulation and return the possible winner.
  fileprivate func runSimulation(stateHistory: [State]) -> Player? {
    var stateHistoryCopy = stateHistory
    var nextState = stateHistoryCopy.last!
    var visitedStates = Set<State>()
    
    var finalWinner: Player? = nil
    
    var sawNewNode = false
    while true {
      let legalMoves = gameSimulator.legalMoves(stateHistory: stateHistoryCopy)
      
      if legalMoves.isEmpty {
        break
      }
      // Choose a move.
      let move = chooseAMove(explore: true, legalMoves: legalMoves, stateHistory: stateHistoryCopy)
      nextState = gameSimulator.nextState(state: nextState, move: move)
      stateHistoryCopy.append(nextState)
      
      let node = nodeFactory.getNode(state: nextState)
      if node.isNewNode() {
        sawNewNode = true
        visitedStates.insert(nextState)
      }
      
      if !sawNewNode {
        visitedStates.insert(nextState)
      }
    
      if let winner = gameSimulator.winner(stateHistory: stateHistoryCopy) {
        finalWinner = winner
        break
      }
    }
    
    let blackWinnerAward: Double
    if finalWinner != nil {
      blackWinnerAward = finalWinner == .BLACK ? 1.0 : 0.0
    } else {
      blackWinnerAward = 0.0
    }
    
    // Update status.
    for state in visitedStates {
      let node = nodeFactory.getNode(state: state)
      node.learn(blackWinningReward: blackWinnerAward)
      numUpdatedNodes += 1
    }
    return finalWinner
  }
  
  // Choose a Move from legalMoves and stateHistory.
  fileprivate func chooseAMove(explore: Bool, legalMoves: [Move], stateHistory: [State]) -> Move {

    let currentState = stateHistory.last!
    let nextPlayer = currentState.nextPlayer
    
    var nodes = [MCTSNode]()
    var totalPlays = 0
    for move in legalMoves {
      let nextState = gameSimulator.nextState(state: currentState, move: move)
      let node = nodeFactory.getNode(state: nextState)
      nodes.append(node)
      totalPlays += node.realGames
    }
    
    let sqrtTotalPlays = sqrt(Double(totalPlays)) * 3
    
    var bestMove: Move? = nil
    var bestPlayOut = 0.0
    var bestProb = 0.0
    var nonExploreMove: Move? = nil
    
    var movePlayout: Dictionary<Move, Double>?
    var moveProb: Dictionary<Move, Double>?
    var topFiveMove: Set<Move>?
    
    if !explore {
      movePlayout = Dictionary<Move, Double>()
      moveProb = Dictionary<Move, Double>()
      topFiveMove = Set<Move>()
    }
    
    for (index, move) in legalMoves.enumerated() {
      let node = nodes[index]
      let games = node.realGames
      
      var playOut = node.blackWinningProbability()
      if nextPlayer == .WHITE {
        playOut = 1.0 - playOut
      }
      
      if playOut > bestProb {
        bestProb = playOut
        nonExploreMove = move
      }

      if explore {
        playOut += sqrtTotalPlays / (1.0 + Double(games))
      } else {
        moveProb![move] = playOut
        movePlayout![move] = playOut + sqrtTotalPlays / (1.0 + Double(games))
        
        if topFiveMove!.count < 5 {
          topFiveMove!.insert(move)
        } else {
          // Maintain top 5
          var currentMinMove = topFiveMove!.first!
          var currentMin = moveProb![currentMinMove]!
          
          for moveInSet in topFiveMove! {
            if moveProb![moveInSet]! < currentMin {
              currentMinMove = moveInSet
              currentMin = moveProb![moveInSet]!
            }
          }
          
          if moveProb![currentMinMove]! < playOut {
            topFiveMove!.remove(currentMinMove)
            topFiveMove!.insert(move)
          }
        }
      }
      
      if playOut > bestPlayOut {
        bestPlayOut = playOut
        bestMove = move
      }
    }
    
    if !explore {
      for moveInSet in topFiveMove! {
        print("Move \(moveInSet): Prob: \(moveProb![moveInSet]!): Explore \(movePlayout![moveInSet]!)")

      }
    }
    
    if nonExploreMove != bestMove {
      self.exploreTimes += 1
    } else {
      self.nonExploreTimes += 1
    }
    return bestMove!
  }
  
  var exploreTimes = 0
  var nonExploreTimes = 0
}
