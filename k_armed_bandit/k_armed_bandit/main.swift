// Configurations.
let verbose = 1
let maxSteps = verbose > 0 ? 10: 1000
let numArms = 10
let numProblems = verbose > 0 ? 2: 2000

// Game starts.

// New policy states for each problem.
func policyFactory() -> [Policy] {
    let policy = RandomPolicy(numActions: numArms)
    return [policy]
}

var policyRewards = Dictionary<String, Double>()
for _ in 0..<numProblems {
    
    let policies = policyFactory()
    let problem = BanditProblem(numArms: numArms, verbose: verbose)
    
    for policy in policies {
        let policyName = policy.name()
        if verbose > 0 {
            print("Policy with name \(policyName)")
        }
        var policyTotalRewardInProblem = 0.0
        
        for i in 0..<maxSteps {
            let action = policy.getAction()
            let currentReward = problem.play(action: action)
            if verbose > 0 {
                print("Step \(i) -- action: \(action) -- reward \(currentReward)")
            }
            policyTotalRewardInProblem += currentReward
        }
        
        let policyAverageRward = policyTotalRewardInProblem / Double(maxSteps)
        if verbose > 0 {
            print("Average rewards in this problem: \(policyAverageRward)")
        }
        
        if policyRewards[policyName] != nil {
            policyRewards[policyName]! += policyAverageRward
        } else {
            policyRewards[policyName] = policyAverageRward
        }
    }
}

for (name, rewards) in policyRewards {
    print("Policy \"\(name)\": \(rewards / Double(numProblems))")
}

