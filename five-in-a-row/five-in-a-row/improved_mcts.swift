import Foundation

fileprivate class MCTSNode {
  
  var hasLearned: Bool = false
  
  var games: Int
  var blackRewards: Double
  var whiteRewards: Double
  
  init(baseBlackWinningProbability: Double,
       baseWhiteWinningProbability: Double,
       basePrioriGames: Int) {

    self.blackRewards = baseBlackWinningProbability * Double(basePrioriGames)
    self.whiteRewards = baseWhiteWinningProbability * Double(basePrioriGames)
    self.games = basePrioriGames
  }
  
  func isNewNode() -> Bool {
    return !hasLearned
  }
  
  func blackWinningProbability() -> Double {
    return blackRewards / Double(games)
  }
  
  func whiteWinningProbability() -> Double {
    return whiteRewards / Double(games)
  }
  
  func learn(blackWinningReward: Double?, whiteWinningReward: Double?) {
    precondition((blackWinningReward == nil) || (whiteWinningReward == nil))
    hasLearned = true
    games += 1
    if blackWinningReward != nil {
      blackRewards += blackWinningReward!
    }
    if whiteWinningReward != nil {
      whiteRewards += whiteWinningReward!
    }
  }
}

fileprivate class MCTSNodeFactory {
  
  var nodePools = Dictionary<State, MCTSNode>()
  let predictor: Predictor
  let basePriorGames = 4
  
  init(predictor: Predictor) {
    self.predictor = predictor
  }
  
  func getNode(state: State) -> MCTSNode {
    if let node = nodePools[state] {
      return node
    } else {
      let baseWinningProbability = predictor.predictWinningProbability(state: state)
      let newNode = MCTSNode(
        baseBlackWinningProbability: baseWinningProbability.black,
        baseWhiteWinningProbability: baseWinningProbability.white,
        basePrioriGames: basePriorGames)
      nodePools[state] = newNode
      return newNode
    }
  }
  
  func saveNodes(storage: Storage) {
    for (state, node) in nodePools {
      if !node.isNewNode() {
        storage.save(state: state,
                     blackWinningProbability: node.blackWinningProbability(),
                     whiteWinningProbability: node.whiteWinningProbability())
      }
    }
  }
}

class ImprovedMCTS: MCTSAlgorithm {
  
  var gameSimulator: GameSimulator
  var storage: Storage?
  
  var numUpdatedNodes = 0
  fileprivate let nodeFactory: MCTSNodeFactory

  init(gameSimulator: GameSimulator, predictor: Predictor, storage: Storage? = nil) {
    self.gameSimulator = gameSimulator
    self.nodeFactory = MCTSNodeFactory(predictor: predictor)
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
    
    var blackWinningAward: Double? = nil
    var whiteWinningAward: Double? = nil
    if finalWinner == .BLACK {
      blackWinningAward = 1.0
    } else if finalWinner == .WHITE {
      whiteWinningAward = 1.0
    }
    
    // Update status.
    for state in visitedStates {
      let node = nodeFactory.getNode(state: state)
      node.learn(blackWinningReward: blackWinningAward, whiteWinningReward: whiteWinningAward)
      numUpdatedNodes += 1
    }
    return finalWinner
  }
  
  // Choose a Move from legalMoves and stateHistory.
  fileprivate func chooseAMove(explore: Bool, legalMoves: [Move], stateHistory: [State]) -> Move {

    let currentState = stateHistory.last!
    let nextPlayer = currentState.nextPlayer
    
    var nodes = [MCTSNode]()
    for move in legalMoves {
      let nextState = gameSimulator.nextState(state: currentState, move: move)
      let node = nodeFactory.getNode(state: nextState)
      nodes.append(node)
    }
    
    if explore && arc4random_uniform(100) < 5 {
      let randomMoveIndex = arc4random_uniform(UInt32(legalMoves.count))
      self.exploreTimes += 1
      return legalMoves[Int(randomMoveIndex)]
    }
    
    self.nonExploreTimes += 1

    var bestMove: Move? = nil
    var bestPlayOut = 0.0
    
    for (index, move) in legalMoves.enumerated() {
      let node = nodes[index]
      
      var playOut: Double
      if nextPlayer == .BLACK {
        playOut = node.blackWinningProbability()
      } else {
        playOut = node.whiteWinningProbability()
      }
      
      if playOut > bestPlayOut {
        bestPlayOut = playOut
        bestMove = move
      }
    }
  
    return bestMove!
  }
  
  var exploreTimes = 0
  var nonExploreTimes = 0
}
