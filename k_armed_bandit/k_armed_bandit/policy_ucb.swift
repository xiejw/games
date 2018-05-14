import Foundation

class UCBPolicy: RewardBasedPolicy {
    let exploreFactor: Double
    var totalCount = 0.0

    init(numActions: Int, stepSize: Double? = nil, exploreFactor: Double = 2.0,
                  name: String = "ucb", verbose: Int = 0) {
        self.exploreFactor = exploreFactor
        super.init(numActions: numActions, stepSize: stepSize, name: name, verbose: verbose)
    }
    
    override func getAction() -> Int {
        totalCount += 1.0

        // Firt pass. Find best reward and unvisted actions.
        var neverVisitedActions = [Int]()
        var bestValue: Double? = nil
        var rewards = [Double?]()
        
        for i in 0..<numActions {
            var reward: Double? = nil
            if visitedCount[i] == 0 {
                neverVisitedActions.append(i)
            } else {
                let exploreValue = exploreFactor * sqrt(log(totalCount) / Double(visitedCount[i]))
                reward = averageRewards[i] + exploreValue
            }
            
            rewards.append(reward)
            if reward == nil {
                continue
            }
            
            if bestValue == nil || reward! > bestValue! {
                bestValue = reward
            }
        }
        
        // If there is any unvisted action, select it (break tie randomly).
        if neverVisitedActions.count > 0 {
          return neverVisitedActions.count == 1 ? neverVisitedActions[0] : neverVisitedActions[random(neverVisitedActions.count)]
        }
        
        // Second pass. Find all good actions.
        var candidates = [Int]()
        for i in 0..<numActions {
            if rewards[i]! == bestValue! {
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
