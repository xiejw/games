import Foundation

class BanditProblem {
    
    let numArms: Int
    var states: [Double]
    
    init(numArms: Int, verbose: Int = 0) {
        self.numArms = numArms
        
        // Generate the states according to normal distribution.
        states = [Double]()
        for i in 0..<numArms {
            let state = normalDistribution()
            if verbose > 0 {
                print("State \(i): \(state)")
            }
            states.append(state)
        }
    }
    
    func play(action: Int) -> Double {
        return normalDistribution(mean: states[action])
    }
}
