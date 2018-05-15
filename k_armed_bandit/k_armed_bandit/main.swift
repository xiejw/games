// Configurations.
let verbose = 0
let maxSteps = verbose > 0 ? 10: 1000
let numArms = verbose > 0 ? 5: 10
let numProblems = verbose > 0 ? 2: 2000
let stationary = true
let monitorEachStep = true

print("""
Configurations:
    verbose: \(verbose)
    numArms: \(numArms)
    maxSteps: \(maxSteps)
    numProblems: \(numProblems)
    stationary: \(stationary)
    monitorEachStep: \(monitorEachStep)
    
""")
if monitorEachStep && !stationary {
    preconditionFailure("Non-stationary should not report each step stats to monitor")
}

// Game starts.
let monitor = Monitor()
monitor.report(key: "total-problems", value: Double(numProblems), skipSummary: false)
monitor.report(key: "total-steps", value: Double(maxSteps), skipSummary: false)

for _ in 0..<numProblems {
    
    // New policies for each problem.
    let policies = policyFactory(numArms: numArms, verbose: verbose)
    let problem = BanditProblem(numArms: numArms, stationary: stationary, verbose: verbose)
    
    // When stationary is false, we need to add a calback to update the best action.
    let (bestActionIndex, bestActionValue) = problem.bestAction()
    
    for policy in policies {
        let policyName = policy.name()
        if verbose > 0 {
            print("Policy with name \(policyName)")
        }
        var policyTotalRewardInProblem = 0.0
        
        for stepIndex in 0..<maxSteps {
            let action = policy.getAction()
            let currentReward = problem.play(action: action)
            if verbose > 0 {
                print("Step \(stepIndex) -- action: \(action) -- reward \(currentReward)")
            }
            policy.learn(action: action, reward: currentReward)
            policyTotalRewardInProblem += currentReward
            
            if monitorEachStep {
                let estimatedValue = policy.getValueEstimate(action: bestActionIndex)
                monitor.report(
                    key: "square-error-(\(policyName))-\(stepIndex)",
                    value: squareError(bestActionValue, estimatedValue))
                monitor.report(
                    key: "best-action-(\(policyName))-\(stepIndex)",
                    value: action == bestActionIndex ? 1.0 : 0.0
                )
            }
        }
        
        let policyAverageRward = policyTotalRewardInProblem / Double(maxSteps)
        if verbose > 0 {
            print("Average rewards in this problem: \(policyAverageRward)")
        }
        
        monitor.report(
            key: "total-reward-(\(policyName))",
            value: policyAverageRward,
            skipSummary: false)
    }
}

monitor.summary()
monitor.save(fName: "/tmp/bandit-data.txt")
