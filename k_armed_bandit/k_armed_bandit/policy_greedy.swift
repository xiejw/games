import Foundation

class RewardBasedPolicy: BasePolicy {
    let stepSize: Double?
    var visitedCount: [Int]
    var averageRewards: [Double]
    
    init(numActions: Int, stepSize: Double? = nil, name: String, verbose: Int = 0) {
        self.stepSize = stepSize
        
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
        let localStepSize = stepSize != nil ? stepSize! : (1 / Double(visitedCount[action]))
        let newReward = oldReward + (reward - oldReward) * localStepSize
        averageRewards[action] = newReward
        if verbose >= printDetailedMessage {
            print("** Policy \"\(policyName)\" learns new reward \(reward)")
            print("  - at visit count \(visitedCount[action])")
            print("  - from \(oldReward) to \(newReward)")
        }
    }
    
}

class EpsilonGreedyPolicy: RewardBasedPolicy {
    let epsilon: Double
    let initialValue: Double
    
    init(numActions: Int, epsilon: Double = 0.1, initialValue: Double = 0.0, stepSize: Double? = nil,
         name: String = "eps-greedy", verbose: Int = 0) {
        self.epsilon = epsilon
        self.initialValue = initialValue

        super.init(numActions: numActions, stepSize: stepSize, name: name, verbose: verbose)
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
