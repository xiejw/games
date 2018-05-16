import Foundation

protocol Policy {
    func name() -> String
    func getAction() -> Int
    func learn(action: Int, reward: Double)
    func getValueEstimate(action: Int) -> Double
}

class BasePolicy: Policy {
    let numActions: Int
    let policyName: String
    let verbose: Int
    let printDetailedMessage = 2

    init(numActions: Int, name: String = "Random", verbose: Int = 0) {
        self.numActions = numActions
        policyName = name
        self.verbose = verbose
    }

    func name() -> String {
        return policyName
    }

    // Unimplemented.
    func getAction() -> Int {
        preconditionFailure("This method must be overridden")
    }

    func learn(action _: Int, reward _: Double) {
        preconditionFailure("This method must be overridden")
    }

    func getValueEstimate(action _: Int) -> Double {
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

    override func learn(action _: Int, reward _: Double) {
        if verbose >= printDetailedMessage {
            print("** Policy \"Random\" does not learn :)")
        }
    }

    override func getValueEstimate(action _: Int) -> Double {
        return 0.0 // Random policy assumes 0.0 for everything.
    }
}
