import Foundation

protocol Policy {
    func name() -> String
    func getAction() -> Int
    func learn(action: Int, reward: Double)
}

class BasePolicy: Policy {
    let numActions: Int
    let policyName: String
    let verbose: Int
    let printDetailedMessage = 2
    
    init(numActions: Int, name: String = "Random", verbose: Int = 0) {
        self.numActions = numActions
        self.policyName = name
        self.verbose = verbose
    }
    
    func name() -> String {
        return policyName
    }
    
    // Unimplemented.
    func getAction() -> Int {
        preconditionFailure("This method must be overridden")
    }
    func learn(action: Int, reward: Double) {
        preconditionFailure("This method must be overridden")
    }
}

class RandomPolicy: BasePolicy {
    override init(numActions: Int, name: String = "Random", verbose: Int = 0) {
        super.init(numActions: numActions, name: name, verbose: verbose)
    }

    override func getAction() -> Int {
        return random(numActions)
    }
    
    override func learn(action: Int, reward: Double) {
        if verbose >= printDetailedMessage {
            print("** Policy \"Random\" does not learn :)")
        }
    }
}


