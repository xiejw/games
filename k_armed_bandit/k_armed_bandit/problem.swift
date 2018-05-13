import Foundation

// Must be stateless after initialization.
class BanditProblem {
    let numArms: Int
    let stationary: Bool
    var states = [Double]()
    
    init(numArms: Int, stationary: Bool, verbose: Int = 0) {
        self.numArms = numArms
        self.stationary = stationary
        self.reset()
    }
    
    func reset() {
        // Generate the states according to normal distribution.
        states = [Double]()
        for _ in 0..<numArms {
            let state = normalDistribution()
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
}
