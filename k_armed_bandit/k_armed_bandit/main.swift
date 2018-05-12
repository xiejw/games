
let verbose = 1
let maxSteps = verbose > 0 ? 10: 1000
let numArms = 10

let problem = BanditProblem(numArms: numArms, verbose: verbose)
let policy = RandomPolicy(numActions: numArms)

var totalRewards = 0.0
for i in 0..<maxSteps {
    let action = policy.getAction()
    let currentReward = problem.play(action: action)
    if verbose > 0 {
        print("Step \(i) -- action: \(action) -- reward \(currentReward)")
    }
    totalRewards += currentReward
}

print("Total rewards \(totalRewards)")
