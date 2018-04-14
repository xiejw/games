// Provides the tooling to play one Game or multiple Games.
import Foundation

func selfPlays(game: Game, board: Board, policies: [Policy], playTimeInSecs: Double) {
  precondition(policies.count == 2)
  precondition(policies[0].getName() != policies[1].getName())
  
  let stats = PlayStats(policies: policies)
  
  let begin = Date().timeIntervalSince1970
  print("Start games at \(formatDate(timeIntervalSince1970: begin)).")
  print("Estimator playing time \(playTimeInSecs) secs.")
  
  while true {
    // Stopping condition.
    let end = NSDate().timeIntervalSince1970 - begin
    if end >= playTimeInSecs {
      break
    }
    
    let (blackPlayerPolicy, whitePlayerPolicy) = randomPermutation(policies: policies)
    let winner = selfPlay(game: game, board: board, blackPlayerPolicy: blackPlayerPolicy, whitePlayerPolicy: whitePlayerPolicy)
    stats.update(winner: winner, blackPlayerPolicy: blackPlayerPolicy, whitePlayerPolicy: whitePlayerPolicy)
  }
  print("End games at \(formatDate(timeIntervalSince1970: Date().timeIntervalSince1970)).")
  stats.summarize()
}

// Play one game.
func selfPlay(game: Game, board: Board, blackPlayerPolicy: Policy, whitePlayerPolicy: Policy,
              verbose: Bool = false) -> Player? {
  var finalWinner: Player? = nil
  
  while true {
    let stateHistory = game.states
    let legalMoves = board.legalMoves(stateHistory: stateHistory)
    if legalMoves.isEmpty {
      if verbose {
        print("No legal moves. Tie")
      }
      break
    }
    
    let nextPlayer = stateHistory.last!.nextPlayer
    if verbose {
      print("Next player: \(nextPlayer)")
    }
    
    var move: Move
    if nextPlayer == .WHITE {
      move = whitePlayerPolicy.getNextMove(stateHistory: stateHistory, legalMoves: legalMoves)
    } else {
      move = blackPlayerPolicy.getNextMove(stateHistory: stateHistory, legalMoves: legalMoves)
    }
    
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
  
  return finalWinner
}

fileprivate class PlayStats {
  var totalGames: Int = 0
  var blackTotalWins: Int = 0
  var whiteTotalWins: Int = 0
  
  var blackWins = Dictionary<String, Int>()
  var whiteWins = Dictionary<String, Int>()
  
  var policyAssignedAsBlack = Dictionary<String, Int>()
  
  let policies: [Policy]
  
  init(policies: [Policy]) {
    self.policies = policies
    precondition(policies.count == 2)
    precondition(policies[0].getName() != policies[1].getName())
    
    blackWins[policies[0].getName()] = 0
    blackWins[policies[1].getName()] = 0
    whiteWins[policies[0].getName()] = 0
    whiteWins[policies[1].getName()] = 0
    
    policyAssignedAsBlack[policies[0].getName()] = 0
    policyAssignedAsBlack[policies[1].getName()] = 0
  }
  
  func update(winner: Player?, blackPlayerPolicy: Policy, whitePlayerPolicy: Policy) {
    totalGames += 1
    policyAssignedAsBlack[blackPlayerPolicy.getName()]! += 1
    
    if winner == nil {
      // Nothing more to update
      return
    }
    
    if winner! == .BLACK {
      blackWins[blackPlayerPolicy.getName()]! += 1
      blackTotalWins += 1
    } else {
      whiteWins[whitePlayerPolicy.getName()]! += 1
      whiteTotalWins += 1
    }
  }
  
  func summarize() {
    print("Total games: \(totalGames)")
    print("Total black wins: \(blackTotalWins)")
    print("Total white wins: \(whiteTotalWins)")
    
    for policy in policies {
      let name = policy.getName()
      print("For policy \(name): as black \(policyAssignedAsBlack[name]!), black wins \(blackWins[name]!), white wins \(whiteWins[name]!)")
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
