import Foundation

class MCTSNode {
  
  var hasLearned: Bool = false
  
  var games: Int
  var blackRewards: Double
  var whiteRewards: Double
  
  let baseBlackRewards: Double
  let baseWhiteRewards: Double
  let basePrioriGames: Int
  
  init(baseBlackRewards: Double,
       baseWhiteRewards: Double,
       basePrioriGames: Int) {
    
    self.blackRewards = baseBlackRewards
    self.whiteRewards = baseWhiteRewards
    self.games = basePrioriGames
    
    self.baseBlackRewards = baseBlackRewards
    self.baseWhiteRewards = baseWhiteRewards
    self.basePrioriGames = basePrioriGames
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
    self.hasLearned = true
    self.games += 1
    if blackWinningReward != nil {
      self.blackRewards += blackWinningReward!
    }
    if whiteWinningReward != nil {
      self.whiteRewards += whiteWinningReward!
    }
  }
}

class MCTSNodeFactory {
  
  var nodePools = Dictionary<State, MCTSNode>()
  let predictor: Predictor
  let basePriorGames = 4
  
  init(predictor: Predictor, rewardsPool: Dictionary<State, Rewards>) {
    self.predictor = predictor
    for (state, rewards) in rewardsPool {
      self.nodePools[state] = MCTSNode(
        baseBlackRewards: rewards.blackRewards,
        baseWhiteRewards: rewards.whiteRewards,
        basePrioriGames: rewards.totalGames)
    }
  }
  
  func getNodePool() -> Dictionary<State, MCTSNode> {
    return nodePools
  }
  
  func trim() {
    var needsToBeTrimed = Set<State>()
    for (state, node) in self.nodePools {
      if node.isNewNode() {
        needsToBeTrimed.insert(state)
      }
    }
    for state in needsToBeTrimed {
      self.nodePools.removeValue(forKey: state)
    }
  }
  
  func getNode(state: State) -> MCTSNode {
    let node = self.nodePools[state]
    if node != nil  {
      return node!
    }
    let baseWinningProbability = self.predictor.predictWinningProbability(state: state)
    let newNode = MCTSNode(
      baseBlackRewards: baseWinningProbability.black * Double(self.basePriorGames),
      baseWhiteRewards: baseWinningProbability.white * Double(self.basePriorGames),
      basePrioriGames: self.basePriorGames)
    self.nodePools[state] = newNode
    return newNode
  }
}

struct Rewards {
  var blackRewards: Double = 0
  var whiteRewards: Double = 0
  var totalGames: Int = 0
  var hasLearned: Bool = false
  
  mutating func merge(node: MCTSNode) {
    blackRewards += node.blackRewards - node.baseBlackRewards
    whiteRewards += node.whiteRewards - node.baseWhiteRewards
    
    if node.games > node.basePrioriGames {
      totalGames += node.games - node.basePrioriGames
      hasLearned = true
    }
  }
}

// Thread safe. Used to distribute and collect simulation results.
class MCTSNodeMerger {
  
  var rewardsPool = Dictionary<State, Rewards>()
  var queue: DispatchQueue
  
  init() {
    self.queue = DispatchQueue(label: "nodeMerger", attributes: .concurrent)
  }
  
  func getRewards() -> Dictionary<State, Rewards> {
    var returnRewardsDict: Dictionary<State, Rewards>? = nil
    self.queue.sync {
      returnRewardsDict = rewardsPool
    }
    return returnRewardsDict!
  }
  
  func merge(newPool: Dictionary<State, MCTSNode>) {
    self.queue.sync(flags: .barrier, execute: {
      print("Merge \(newPool.count) nodes")
      var skipped = 0
      for (state, node) in newPool {
        if node.isNewNode() {
          skipped += 1
          continue
        }
        var currentRewards = self.rewardsPool[state]
        if currentRewards != nil {
          currentRewards!.merge(node: node)
        } else {
          let hasLearned = node.games > node.basePrioriGames
          let rewards = Rewards(blackRewards: node.blackRewards,
                                whiteRewards: node.whiteRewards,
                                totalGames: node.games,
                                hasLearned: hasLearned)
          self.rewardsPool[state] = rewards
        }
      }
      print("Merge \(newPool.count) nodes done. Skipped \(skipped)")
      print("Current saved rewards \(self.rewardsPool.count)")
    })
  }
  
  func saveNodes(storage: Storage) {
    self.queue.sync {
      for (state, rewards) in rewardsPool {
        let black = rewards.blackRewards / Double(rewards.totalGames)
        let white = rewards.whiteRewards / Double(rewards.totalGames)
        storage.save(state: state,
                     blackWinningProbability: black,
                     whiteWinningProbability: white)
      }
    }
  }
}
