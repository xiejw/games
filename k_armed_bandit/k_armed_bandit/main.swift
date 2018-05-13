// Configurations.
let verbose = 0
let maxSteps = verbose > 0 ? 10: 1000
let numArms = 10
let numProblems = verbose > 0 ? 2: 2000
let stationary = false

print("""
Configurations:
    verbose: \(verbose)
    numArms: \(numArms)
    maxSteps: \(maxSteps)
    numProblems: \(numProblems)
    stationary: \(stationary)
    
""")
// Game starts.

// New policy states for each problem.
func policyFactory() -> [Policy] {
    var policies = [Policy]()
    policies.append(RandomPolicy(numActions: numArms, verbose: verbose))

    // Basic Group: Examine the reproducibility.
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.0, name: "eps-0.0a", verbose: verbose))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.0, name: "eps-0.0b", verbose: verbose))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.01, name: "eps-0.01a", verbose: verbose))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.01, name: "eps-0.01b", verbose: verbose))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.05, name: "eps-0.05a", verbose: verbose))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.05, name: "eps-0.05b", verbose: verbose))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.1, name: "eps-0.1a", verbose: verbose))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.1, name: "eps-0.1b", verbose: verbose))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.2, name: "eps-0.2a", verbose: verbose))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.2, name: "eps-0.2b", verbose: verbose))
    
    // Second Group: Test stationary and initial value.
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.0, initialValue: 5.0, name: "eps-0.0-5"))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.0, initialValue: 0.0, name: "eps-0.0-0"))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.01, initialValue: 5.0, name: "eps-0.01-5"))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.01, initialValue: 0.0, name: "eps-0.01-0"))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.05, initialValue: 5.0, name: "eps-0.05-5"))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.05, initialValue: 0.0, name: "eps-0.05-0"))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.1, initialValue: 5.0, name: "eps-0.1-5"))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.1, initialValue: 0.0, name: "eps-0.1-0"))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.2, initialValue: 5.0, name: "eps-0.2-5"))
//    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.2, initialValue: 0.0, name: "eps-0.2-0"))
    
    // Third Group: constant step size.
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.0, name: "eps-0.0"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.01, name: "eps-0.01"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.05, name: "eps-0.05"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.1, name: "eps-0.1"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.2, name: "eps-0.2"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.0, stepSize: 0.1, name: "eps-0.0-s1"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.01, stepSize: 0.1, name: "eps-0.01-s1"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.05, stepSize: 0.1, name: "eps-0.05-s1"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.1, stepSize: 0.1, name: "eps-0.1-s1"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.2, stepSize: 0.1, name: "eps-0.2-s1"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.0, stepSize: 0.2, name: "eps-0.0-s2"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.01, stepSize: 0.2, name: "eps-0.01-s2"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.05, stepSize: 0.2, name: "eps-0.05-s2"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.1, stepSize: 0.2, name: "eps-0.1-s2"))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.2, stepSize: 0.2, name: "eps-0.2-s2"))
    return policies
}

var policyRewards = Dictionary<String, Double>()
for _ in 0..<numProblems {
    
    let policies = policyFactory()
    let problem = BanditProblem(numArms: numArms, stationary: stationary, verbose: verbose)
    
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
            policy.learn(action: action, reward: currentReward)
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

for (name, rewards) in (policyRewards.sorted{ $0.0 < $1.0 }) {
    print("Policy \"\(name)\": \(rewards / Double(numProblems))")
}

