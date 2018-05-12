import Foundation

// Must be stateless after initialization.
class BanditProblem {
    let numArms: Int
    var states: [Double]
    
    init(numArms: Int, verbose: Int = 0) {
        self.numArms = numArms
        
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
        return normalDistribution(mean: states[action])
    }
}
