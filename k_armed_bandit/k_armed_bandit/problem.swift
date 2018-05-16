import Foundation

// Must be stateless after initialization.
class BanditProblem {
    let numArms: Int
    let stationary: Bool
    var states = [Double]()

    var bestActionIndex = 0

    init(numArms: Int, stationary: Bool, verbose _: Int = 0) {
        self.numArms = numArms
        self.stationary = stationary
        reset()
    }

    func reset() {
        // During reset, also record the bestActionIndex.
        var bestValue: Double?

        // Generate the states according to normal distribution.
        states = [Double]()
        for i in 0 ..< numArms {
            let state = normalDistribution()
            if bestValue == nil || state > bestValue! {
                bestValue = state
                bestActionIndex = i
            }
            states.append(state)
        }
        if verbose > 0 {
            print("New Problem with states \(states)")
        }
    }

    func play(action: Int) -> Double {
        if !stationary && random(100) < 1 {
            reset()
        }
        return normalDistribution(mean: states[action])
    }

    func bestAction() -> (bestActionIndex: Int, bestActionValue: Double, actionRanking: Dictionary<Int, Int>) {
        var actionValues = Dictionary<Int, Double>()
        for i in 0 ..< numArms {
            actionValues[i] = states[i]
        }
        var actionRanking = Dictionary<Int, Int>()
        var ranking = 0
        for (actionIndex, _) in (actionValues.sorted { $0.1 > $1.1 }) {
            actionRanking[actionIndex] = ranking
            ranking += 1
        }
        assert(ranking == numArms)
        assert(actionRanking[bestActionIndex] == 0)
        return (bestActionIndex, states[bestActionIndex], actionRanking)
    }
}
