// Provides the tooling to play one Game or multiple Games.
import Foundation

func selfPlays(gameFn: @escaping () -> Game, policyFn: @escaping () -> [Policy], board: Board, storage: CSVStorage?,
               playTimeInSecs: Double, verbose: Int) {
  
  let defaultPolicies = policyFn()
  precondition(defaultPolicies.count == 2)
  precondition(defaultPolicies[0].getName() != defaultPolicies[1].getName())
  
  let finalStats = PlayStats(policies: defaultPolicies, name: "final")
  
  let begin = Date().timeIntervalSince1970
  print("Start games at \(formatDate(timeIntervalSince1970: begin)).")
  print("Estimator playing time \(playTimeInSecs) secs.")
  
  let queue = DispatchQueue(label: "games", attributes: .concurrent)
  let group = DispatchGroup()
  
  for i in 0..<8 {
    group.enter()
    queue.async {
      selfPlayAndRecord(currentBranch: i,
                        beginTime: begin,
                        gameFn: gameFn,
                        policyFn: policyFn,
                        finalStats: finalStats,
                        board: board,
                        storage: storage,
                        playTimeInSecs: playTimeInSecs,
                        verbose: verbose)
      group.leave()
    }
  }
  group.wait()
  print("End games at \(formatDate(timeIntervalSince1970: Date().timeIntervalSince1970)).")
  finalStats.summarize()
}

fileprivate func selfPlayAndRecord(currentBranch i: Int,
                                   beginTime begin: Double,
                                   gameFn: @escaping () -> Game,
                                   policyFn: @escaping () -> [Policy],
                                   finalStats: PlayStats,
                                   board: Board,
                                   storage: CSVStorage?,
                                   playTimeInSecs: Double,
                                   verbose: Int) {

  // Policies are immutable.
  let policies = policyFn()
  let stats = PlayStats(policies: policies, name: "sub-branch-\(i)")
  
  var playRecords = Dictionary<Player, [PlayRecord]>()
  playRecords[.BLACK] = [PlayRecord]()
  playRecords[.WHITE] = [PlayRecord]()
  
  // FIXME
  var totalGamesInThread = 0.0
  var totalHistoryAppended = 0.0
  var totalRecordSeen = 0.0
  var totalHisotrySeen = 0.0
  var totalBlackRecord = 0.0
  var totalBlackRecordTotal = 0.0
  var totalWhiteRecordTotal = 0.0
  
  while true {
    // Stopping condition.
    let end = NSDate().timeIntervalSince1970 - begin
    if end >= playTimeInSecs {
      break
    }
    // Game is stateful. Creates a new game each time.
    let game = gameFn()
    
    let (blackPlayerPolicy, whitePlayerPolicy) = randomPermutation(policies: policies)
    let (winner, history) = selfPlay(game: game, board: board, blackPlayerPolicy: blackPlayerPolicy, whitePlayerPolicy: whitePlayerPolicy)
    stats.update(winner: winner, blackPlayerPolicy: blackPlayerPolicy, whitePlayerPolicy: whitePlayerPolicy)
    
    totalHisotrySeen += Double(history.count)
    precondition(history.count == 2)
    for k in history.keys {
      precondition(k == Player.WHITE || k == Player.BLACK)
    }
    totalBlackRecordTotal += Double(history[.BLACK]!.count)
    totalWhiteRecordTotal += Double(history[.WHITE]!.count)
    
    //FIXME
    totalGamesInThread += 1
    
    if blackPlayerPolicy.shouldRecord() {
      totalHistoryAppended += 1
      let reward: Double
      if winner == nil {
        reward = 0.0
      } else {
        reward = winner == .BLACK ? 1.0 : -1.0
      }
      totalBlackRecord += Double(history[.BLACK]!.count)
      for item in history[.BLACK]! {
        totalRecordSeen += 1
        playRecords[.BLACK]!.append(PlayRecord(history: item, reward: reward))
        
      }
    }
    
    if whitePlayerPolicy.shouldRecord() {
      let reward: Double
      if winner == nil {
        reward = 0.0
      } else {
        reward = winner == .WHITE ? 1.0 : -1.0
      }
      for item in history[.WHITE]! {
        playRecords[.WHITE]!.append(PlayRecord(history: item, reward: reward))
      }
    }
  }
  
  if verbose > 0 {
    print("Finish games ([\(i)]) at \(formatDate(timeIntervalSince1970: Date().timeIntervalSince1970)).")
  }
  print("Thread \(i) \(totalGamesInThread) history seen \(totalHisotrySeen) totalBlackRecordTotal \(totalBlackRecordTotal) totalWhiteRecordTotal \(totalWhiteRecordTotal)  totalBlackRecord \(totalBlackRecord) historyRecord seen \(totalRecordSeen) total records \(totalHistoryAppended) black \(playRecords[.BLACK]!.count) white \(playRecords[.WHITE]!.count)")
  
  
  finalStats.merge(stats)
  
  print("Thread \(i) \(totalGamesInThread)   total records \(totalHistoryAppended) black \(playRecords[.BLACK]!.count) white \(playRecords[.WHITE]!.count)")
  if storage != nil {
    //FIXME
    var savedGames = 0
    for player in [Player.BLACK, Player.WHITE] {
      for record in playRecords[player]! {
        savedGames += 1
        storage!.save(state: record.history.state, nextPlayer: player,
                      legalMoves: record.history.legalMoves, distribution: record.history.unnormalizedProb,
                      reward: record.reward)
      }
    }
    
    //FIXME
    print("Thread \(i) \(totalGamesInThread)  saved \(savedGames)  total records \(totalHistoryAppended) black \(playRecords[.BLACK]!.count) white \(playRecords[.WHITE]!.count)")
  }
  if verbose > 0 {
    print("Finish recording ([\(i)]) at \(formatDate(timeIntervalSince1970: Date().timeIntervalSince1970)).")
  }
}

// Play one game.
func selfPlay(game: Game, board: Board, blackPlayerPolicy: Policy, whitePlayerPolicy: Policy,
              verbose: Bool = false) -> (Player?, Dictionary<Player, [PlayHistory]>) {
  var finalWinner: Player? = nil
  var history = Dictionary<Player, [PlayHistory]>()
  history[.BLACK] = [PlayHistory]()
  history[.WHITE] = [PlayHistory]()
  
  while true {
    let stateHistory = game.states
    let legalMoves = board.legalMoves(stateHistory: stateHistory)
    if legalMoves.isEmpty {
      if verbose {
        print("No legal moves. Tie")
      }
      break
    }
    
    let currentState = stateHistory.last!
    let nextPlayer = currentState.nextPlayer
    if verbose {
      print("Next player: \(nextPlayer)")
    }
    
    var move: Move
    var unnormalizedProb: [Double]
    if nextPlayer == .WHITE {
      (move, unnormalizedProb) = whitePlayerPolicy.getNextMove(stateHistory: stateHistory, legalMoves: legalMoves)
    } else {
      (move, unnormalizedProb) = blackPlayerPolicy.getNextMove(stateHistory: stateHistory, legalMoves: legalMoves)
    }
    
    let historyItem = PlayHistory(state: currentState, move: move, legalMoves: legalMoves, unnormalizedProb: unnormalizedProb)
    history[nextPlayer]!.append(historyItem)
    
    try! game.newMove(move)
    
    if verbose {
      print("Next move: \(move)")
      game.print()
    }
    if let winner = board.winner(stateHistory: game.states) {
      if verbose {
        print("We have a winner \(winner)")
      }
      finalWinner = winner
      break
    }
  }
  
  precondition(history.count >= 1)
  
  return (finalWinner, history)
}

struct PlayHistory {
  var state: State
  var move: Move
  var legalMoves: [Move]
  var unnormalizedProb: [Double]
}

struct PlayRecord {
  var history: PlayHistory
  var reward: Double
}

fileprivate class PlayStats {
  var totalGames: Int = 0
  var blackTotalWins: Int = 0
  var whiteTotalWins: Int = 0
  
  var blackWins = Dictionary<String, Int>()
  var whiteWins = Dictionary<String, Int>()
  
  var policyAssignedAsBlack = Dictionary<String, Int>()
  
  var queue: DispatchQueue
  
  let policies: [Policy]
  
  init(policies: [Policy], name: String) {
    self.policies = policies
    precondition(policies.count == 2)
    precondition(policies[0].getName() != policies[1].getName())
    
    blackWins[policies[0].getName()] = 0
    blackWins[policies[1].getName()] = 0
    whiteWins[policies[0].getName()] = 0
    whiteWins[policies[1].getName()] = 0
    
    policyAssignedAsBlack[policies[0].getName()] = 0
    policyAssignedAsBlack[policies[1].getName()] = 0
    
    queue = DispatchQueue(label: name + "stat", attributes: .concurrent)
  }
  
  // Not thread safe
  func update(winner: Player?, blackPlayerPolicy: Policy, whitePlayerPolicy: Policy) {
    self.totalGames += 1
    self.policyAssignedAsBlack[blackPlayerPolicy.getName()]! += 1
    
    if winner == nil {
      // Nothing more to update
      return
    }
    
    if winner! == .BLACK {
      self.blackWins[blackPlayerPolicy.getName()]! += 1
      self.blackTotalWins += 1
    } else {
      self.whiteWins[whitePlayerPolicy.getName()]! += 1
      self.whiteTotalWins += 1
    }
  }
  
  func merge(_ anotherStats: PlayStats) {
    queue.sync(flags: .barrier, execute: {
      self.totalGames += anotherStats.totalGames
      self.blackTotalWins += anotherStats.blackTotalWins
      self.whiteTotalWins += anotherStats.whiteTotalWins
      
      for policy in self.policies {
        let name = policy.getName()
        self.blackWins[name]! += anotherStats.blackWins[name]!
        self.whiteWins[name]! += anotherStats.whiteWins[name]!
        self.policyAssignedAsBlack[name]! += anotherStats.policyAssignedAsBlack[name]!
      }
    })
  }
  
  func summarize() {
    queue.sync {
      print("Total games: \(self.totalGames)")
      print("Total black wins: \(self.blackTotalWins)")
      print("Total white wins: \(self.whiteTotalWins)")
      
      for policy in self.policies {
        let name = policy.getName()
        print("For policy \(name): as black \(self.policyAssignedAsBlack[name]!), black wins \(self.blackWins[name]!), white wins \(self.whiteWins[name]!)")
      }
    }
  }
}

fileprivate func randomPermutation(policies: [Policy]) -> (Policy, Policy) {
  precondition(policies.count == 2)
  let n = Int(arc4random_uniform(10))
  if n < 5 {
    return (policies[0], policies[1])
  } else {
    return (policies[1], policies[0])
  }
}
