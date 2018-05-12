import Foundation

protocol Policy {
    func getAction() -> Int
}

class RandomPolicy: Policy {
    
    let numActions: Int
    
    init(numActions: Int) {
        self.numActions = numActions
    }
    
    func getAction() -> Int {
        return random(numActions)
    }
}


