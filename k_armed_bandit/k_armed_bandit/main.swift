// Configurations.
let verbose = 0
let maxSteps = verbose > 0 ? 10: 1000
let numArms = 10
let numProblems = verbose > 0 ? 2: 2000

// Game starts.

let policy = RandomPolicy(numActions: numArms)

var policyRewards = 0.0
for _ in 0..<numProblems {
    let problem = BanditProblem(numArms: numArms, verbose: verbose)
    var totalRewards = 0.0
    for i in 0..<maxSteps {
        let action = policy.getAction()
        let currentReward = problem.play(action: action)
        if verbose > 0 {
            print("Step \(i) -- action: \(action) -- reward \(currentReward)")
        }
        totalRewards += currentReward
    }
    totalRewards /= Double(maxSteps)
    policyRewards += totalRewards
    if verbose > 0 {
        print("Total rewards \(totalRewards)")
    }
}
policyRewards /= Double(numProblems)
print("Policy \"\(policy.name())\" average rewards \(policyRewards)")


