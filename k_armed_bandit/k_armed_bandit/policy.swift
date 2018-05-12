import Foundation

protocol Policy {
    func name() -> String
    func getAction() -> Int
    
}

class RandomPolicy: Policy {
    let numActions: Int
    let policyName: String
    
    init(numActions: Int, name: String = "Random") {
        self.numActions = numActions
        self.policyName = name
    }
    
    func name() -> String {
        return policyName
    }
    
    func getAction() -> Int {
        return random(numActions)
    }
}


