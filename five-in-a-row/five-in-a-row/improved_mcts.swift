import Foundation

class ImprovedMCTS: MCTSAlgorithm {
  
  var board: Board
  var storage: Storage?
  var predictorFn: () -> Predictor
  
  var numUpdatedNodes = 0
  
  fileprivate let nodes: MCTSNodeMerger

  init(board: Board, predictorFn:  @escaping () -> Predictor, storage: Storage? = nil) {
    self.board = board
    self.predictorFn = predictorFn
    self.storage = storage
    
    self.nodes = MCTSNodeMerger()
  }
  
  func selfPlay(stateHistory: [State], calculationTime: Double) {
    let simulationStats = runSimulations(stateHistory: stateHistory,
                                         calculationTime: calculationTime)
    print(simulationStats)
    if storage != nil {
      nodes.saveNodes(storage: storage!)
    }
  }
  
  func getNextMove(stateHistory: [State], calculationTime: Double) -> Move? {
    let simulationStats = runSimulations(stateHistory: stateHistory,
                                         calculationTime: calculationTime)


    // Find the best move.
    let legalMoves = board.legalMoves(stateHistory: stateHistory)
    let currentRewardsPool = self.nodes.getRewards()
    let nodeFactory = MCTSNodeFactory(predictor: self.predictorFn(), rewardsPool: currentRewardsPool)
    let move = chooseAMove(explore: false,
                           legalMoves: legalMoves,
                           stateHistory: stateHistory,
                           nodeFactory: nodeFactory)
    
    print(simulationStats)
    return move
    return nil
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
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "simulations", attributes: .concurrent)

    let currentRewardsPool = self.nodes.getRewards()
    
    for i in 0..<8 {
      dispatchGroup.enter()
      dispatchQueue.async {
        let nodeFactory = MCTSNodeFactory(predictor: self.predictorFn(), rewardsPool: currentRewardsPool)
        var end = NSDate().timeIntervalSince1970 - begin
        while  end < calculationTime {
          let player = self.runSimulation(stateHistory: stateHistory, nodeFactory: nodeFactory)
          dispatchGroup.enter()
          dispatchQueue.async(flags: .barrier) {
            if player == .BLACK {
              blackWins += 1
            } else if player == .WHITE {
              whiteWins += 1
            }
            games += 1
            dispatchGroup.leave()
          }
          end = NSDate().timeIntervalSince1970 - begin
        }
        print("I am done \(i)")
        self.nodes.merge(newPool: nodeFactory.getNodePool())
        print("I am merged \(i)")
        dispatchGroup.leave()
      }
    }
    dispatchGroup.wait()
    print("Num of Updates \(numUpdatedNodes)")
    print("Nonexplore moves \(self.nonExploreTimes)")
    print("Explore moves \(self.exploreTimes)")
    
    var stats: SimuationStats? = nil
    dispatchQueue.sync {
      stats = SimuationStats(blackWins: blackWins,
                             whiteWins: whiteWins,
                             games: games,
                             startTime: begin,
                             endTime: begin + calculationTime)
    }
    return stats!
  }
  
  // Run one simulation and return the possible winner.
  fileprivate func runSimulation(stateHistory: [State], nodeFactory: MCTSNodeFactory) -> Player? {
    var stateHistoryCopy = stateHistory
    var nextState = stateHistoryCopy.last!
    var visitedStates = Set<State>()
    
    var finalWinner: Player? = nil
    
    var sawNewNode = false
    while true {
      let legalMoves = board.legalMoves(stateHistory: stateHistoryCopy)
      
      if legalMoves.isEmpty {
        break
      }
      // Choose a move.
      let move = chooseAMove(explore: true,
                             legalMoves: legalMoves,
                             stateHistory: stateHistoryCopy,
                             nodeFactory: nodeFactory)
      nextState = board.nextState(state: nextState, move: move)
      stateHistoryCopy.append(nextState)
      
      let node = nodeFactory.getNode(state: nextState)
      if node.isNewNode() {
        sawNewNode = true
        visitedStates.insert(nextState)
      }
      
      if !sawNewNode {
        visitedStates.insert(nextState)
      }
    
      if let winner = board.winner(stateHistory: stateHistoryCopy) {
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
    
    // Maintaince.
    nodeFactory.trim()
    return finalWinner
  }
  
  // Choose a Move from legalMoves and stateHistory.
  fileprivate func chooseAMove(explore: Bool, legalMoves: [Move], stateHistory: [State],
                               nodeFactory: MCTSNodeFactory) -> Move {

    let currentState = stateHistory.last!
    let nextPlayer = currentState.nextPlayer
    
    var nodes = [MCTSNode]()
    for move in legalMoves {
      let nextState = board.nextState(state: currentState, move: move)
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
