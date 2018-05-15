import Foundation

func policyFactory(numArms: Int, verbose: Int) -> [Policy] {
    var policies = [Policy]()
    // Base line. should be 0.
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
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.0, name: "eps-0.0"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.01, name: "eps-0.01"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.05, name: "eps-0.05"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.1, name: "eps-0.1"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.2, name: "eps-0.2"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.0, stepSize: 0.1, name: "eps-0.0-s1"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.01, stepSize: 0.1, name: "eps-0.01-s1"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.05, stepSize: 0.1, name: "eps-0.05-s1"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.1, stepSize: 0.1, name: "eps-0.1-s1"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.2, stepSize: 0.1, name: "eps-0.2-s1"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.0, stepSize: 0.2, name: "eps-0.0-s2"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.01, stepSize: 0.2, name: "eps-0.01-s2"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.05, stepSize: 0.2, name: "eps-0.05-s2"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.1, stepSize: 0.2, name: "eps-0.1-s2"))
    //    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.2, stepSize: 0.2, name: "eps-0.2-s2"))
    
    // Final group: All (explore parameter matters.)
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.05, name: "eps-0.05", verbose: verbose))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.1, name: "eps-0.1", verbose: verbose))
    
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.05, initialValue: 5.0, name: "eps-0.05-5", verbose: verbose))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.1, initialValue: 5.0, name: "eps-0.1-5", verbose: verbose))
    
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.05, initialValue: 5.0, stepSize: 0.2, name: "eps-0.05-5-s", verbose: verbose))
    policies.append(EpsilonGreedyPolicy(numActions: numArms, epsilon: 0.1, initialValue: 5.0, stepSize: 0.2, name: "eps-0.1-5-s", verbose: verbose))
    
    policies.append(UCBPolicy(numActions: numArms, name: "ucb", verbose: verbose))
    policies.append(UCBPolicy(numActions: numArms, exploreFactor: 1.0, name: "ucb-1", verbose: verbose))
    policies.append(UCBPolicy(numActions: numArms,  exploreFactor: 1.414, name: "ucb-1.414", verbose: verbose))
    policies.append(UCBPolicy(numActions: numArms,  exploreFactor: 0.8, name: "ucb-0.8", verbose: verbose))
    policies.append(UCBPolicy(numActions: numArms,  exploreFactor: 0.5, name: "ucb-0.5", verbose: verbose))
    
    policies.append(UCBPolicy(numActions: numArms, stepSize: 0.2, name: "ucb-s", verbose: verbose))
    policies.append(UCBPolicy(numActions: numArms, stepSize: 0.2, exploreFactor: 1.0, name: "ucb-s-1", verbose: verbose))
    policies.append(UCBPolicy(numActions: numArms, stepSize: 0.2, exploreFactor: 1.414, name: "ucb-s-1.414", verbose: verbose))
    policies.append(UCBPolicy(numActions: numArms, stepSize: 0.2, exploreFactor: 0.8, name: "ucb-s-0.8", verbose: verbose))
    policies.append(UCBPolicy(numActions: numArms, stepSize: 0.2, exploreFactor: 0.5, name: "ucb-s-0.5", verbose: verbose))
    return policies
}
