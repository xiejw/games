import Foundation

// Must be stateless after initialization.
class BanditProblem {
    let numArms: Int
    let stationary: Bool
    var states = [Double]()
    
    var bestActionIndex = 0
    
    init(numArms: Int, stationary: Bool, verbose: Int = 0) {
        self.numArms = numArms
        self.stationary = stationary
        self.reset()
    }
    
    func reset() {
        // During reset, also record the bestActionIndex.
        var bestValue : Double? = nil
        
        // Generate the states according to normal distribution.
        states = [Double]()
        for i in 0..<numArms {
            let state = normalDistribution()
            if bestValue == nil || state > bestValue! {
                bestValue = state
                self.bestActionIndex = i
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
    
    func bestAction() -> (Int, Double) {
        return (bestActionIndex, states[bestActionIndex])
    }
}
