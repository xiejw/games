import Foundation

protocol Policy {
    func name() -> String
    func getAction() -> Int
    func learn(action: Int, reward: Double)
}

class BasePolicy: Policy {
    let numActions: Int
    let policyName: String
    let verbose: Int
    let printDetailedMessage = 2
    
    init(numActions: Int, name: String = "Random", verbose: Int = 0) {
        self.numActions = numActions
        self.policyName = name
        self.verbose = verbose
    }
    
    func name() -> String {
        return policyName
    }
    
    // Unimplemented.
    func getAction() -> Int {
        preconditionFailure("This method must be overridden")
    }
    func learn(action: Int, reward: Double) {
        preconditionFailure("This method must be overridden")
    }
}

class RandomPolicy: BasePolicy {
    override init(numActions: Int, name: String = "Random", verbose: Int = 0) {
        super.init(numActions: numActions, name: name, verbose: verbose)
    }

    override func getAction() -> Int {
        return random(numActions)
    }
    
    override func learn(action: Int, reward: Double) {
        if verbose >= printDetailedMessage {
            print("** Policy \"Random\" does not learn :)")
        }
    }
}

class EpsilonGreedyPolicy: BasePolicy {
    let epsilon: Double
    let initialValue: Double

    var visitedCount: [Int]
    var averageRewards: [Double]
    
    init(numActions: Int, epsilon: Double = 0.1, initialValue: Double = 0.0,
         name: String = "eps-greedy", verbose: Int = 0) {
        self.epsilon = epsilon
        self.initialValue = initialValue
  
        visitedCount = [Int]()
        averageRewards = [Double]()
        for _ in 0..<numActions {
            visitedCount.append(0)
            averageRewards.append(0.0)
        }
        super.init(numActions: numActions, name: name, verbose: verbose)
    }
    
    override func learn(action: Int, reward: Double) {
        visitedCount[action] += 1
        let oldReward = averageRewards[action]
        let newReward = oldReward + (reward - oldReward) / Double(visitedCount[action])
        averageRewards[action] = newReward
        if verbose >= printDetailedMessage {
            print("** Policy \"\(policyName)\" learns new reward \(reward)")
            print("  - at visit count \(visitedCount[action])")
            print("  - from \(oldReward) to \(newReward)")
        }
    }
    
    override func getAction() -> Int {
        // Go random?
        let dice = Double(random(100)) / 100.0
        if  dice <= epsilon {
            if verbose >= printDetailedMessage {
                print("** Policy \"\(policyName)\" explores: \(dice) <= \(epsilon) ")
            }
            return random(numActions)
        }
        
        // Firt pass. Find best reward
        var bestValue: Double? = nil
        var rewards = [Double]()
        
        for i in 0..<numActions {
            let reward: Double
            if visitedCount[i] == 0 {
                reward = initialValue
            } else {
                reward = averageRewards[i]
            }

            rewards.append(reward)
            if i == 0 {
                bestValue = reward
            } else if reward > bestValue! {
                bestValue = reward
            }
        }
        
        // Second pass. Find all good actions.
        var candidates = [Int]()
        for i in 0..<numActions {
            if rewards[i] == bestValue! {
                candidates.append(i)
            }
        }
        if verbose >= printDetailedMessage {
            print("** Policy \"\(policyName)\" best value \(bestValue!)")
            print("   - candidates: \(candidates)")
        }
        
        // Finally. Break the tie
        precondition(candidates.count >= 1)
        let action = candidates.count == 1 ? candidates[0] : candidates[random(candidates.count)]
        return action
    }
}


