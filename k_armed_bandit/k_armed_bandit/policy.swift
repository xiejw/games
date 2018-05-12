import Foundation

protocol Policy {
    func name() -> String
    func getAction() -> Int
    
}

class BasePolicy: Policy {
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
        preconditionFailure("This method must be overridden")
    }
}

class RandomPolicy: BasePolicy {
    override init(numActions: Int, name: String = "Random") {
        super.init(numActions: numActions, name: name)
    }

    override func getAction() -> Int {
        return random(numActions)
    }
}

class EpsilonGreedyPolicy: BasePolicy {
    let epsilon: Double
    let intialValue: Double
    var visitedCount: [Int]
    var averageRewards: [Double]
    
    init(numActions: Int, epsilon: Double = 0.1, intialValue: Double = 0.0, name: String = "eps-greedy") {
        self.epsilon = epsilon
        self.intialValue = intialValue
  
        visitedCount = [Int]()
        averageRewards = [Double]()
        for _ in 0..<numActions {
            visitedCount.append(0)
            averageRewards.append(0.0)
        }
        super.init(numActions: numActions, name: name)
    }
    
    override func getAction() -> Int {
        
        // break tie
        return random(numActions)
    }
}


