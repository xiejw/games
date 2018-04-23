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
  
  for i in 0..<1 {
    group.enter()
    queue.async {
      let game = gameFn()
      let policies = policyFn()
      let stats = PlayStats(policies: policies, name: "sub-branch-\(i)")
      var playRecords = Dictionary<Player, [PlayRecord]>()
      playRecords[.BLACK] = [PlayRecord]()
      playRecords[.WHITE] = [PlayRecord]()

      while true {
        // Stopping condition.
        let end = NSDate().timeIntervalSince1970 - begin
        if end >= playTimeInSecs {
          break
        }
        
        let (blackPlayerPolicy, whitePlayerPolicy) = randomPermutation(policies: policies)
        let (winner, history) = selfPlay(game: game, board: board, blackPlayerPolicy: blackPlayerPolicy, whitePlayerPolicy: whitePlayerPolicy)
        stats.update(winner: winner, blackPlayerPolicy: blackPlayerPolicy, whitePlayerPolicy: whitePlayerPolicy)
        
        if winner != nil && blackPlayerPolicy.shouldRecord() {
          let blackWin = winner == .BLACK
          for item in history[.BLACK]! {
            playRecords[.BLACK]!.append(PlayRecord(history: item, win: blackWin))
          }
        }
        
        if winner != nil && whitePlayerPolicy.shouldRecord() {
          let whitekWin = winner == .WHITE
          for item in history[.WHITE]! {
            playRecords[.WHITE]!.append(PlayRecord(history: item, win: whitekWin))
          }
        }
      }
      
      if verbose > 0 {
        print("Finish games ([\(i)]) at \(formatDate(timeIntervalSince1970: Date().timeIntervalSince1970)).")
      }
      finalStats.merge(stats)
      if storage != nil {
        for player in [Player.BLACK, Player.WHITE] {
          for record in playRecords[player]! {
            storage!.save(state: record.history.state, nextPlayer: player, move: record.history.move, win: record.win)
          }
        }
      }
      if verbose > 0 {
        print("Finish recording ([\(i)]) at \(formatDate(timeIntervalSince1970: Date().timeIntervalSince1970)).")
      }
      group.leave()
    }
  }
  group.wait()
  print("End games at \(formatDate(timeIntervalSince1970: Date().timeIntervalSince1970)).")
  finalStats.summarize()
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
    if nextPlayer == .WHITE {
      move = whitePlayerPolicy.getNextMove(stateHistory: stateHistory, legalMoves: legalMoves)
    } else {
      move = blackPlayerPolicy.getNextMove(stateHistory: stateHistory, legalMoves: legalMoves)
    }
    
    history[nextPlayer]!.append(PlayHistory(state: currentState, move: move))
    
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
  
  return (finalWinner, history)
}

struct PlayHistory {
  var state: State
  var move: Move
}

struct PlayRecord {
  var history: PlayHistory
  var win: Bool
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