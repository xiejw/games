import Foundation

struct PlayHistory {
    var state: State
    var move: Move
    var legalMoves: [Move]
    var unnormalizedProb: [Double]
}

class PlayStats {
    var totalGames: Int = 0
    var totalMoves: Int = 0
    var blackTotalWins: Int = 0
    var whiteTotalWins: Int = 0

    var blackWins = Dictionary<String, Int>()
    var whiteWins = Dictionary<String, Int>()

    var policyAssignedAsBlack = Dictionary<String, Int>()

    var queue: DispatchQueue

    let policies: [Policy]

    init(policies: [Policy], name: String) {
        self.policies = policies
        precondition(policies.count == 2)
        precondition(policies[0].getName() != policies[1].getName())

        blackWins[policies[0].getName()] = 0
        blackWins[policies[1].getName()] = 0
        whiteWins[policies[0].getName()] = 0
        whiteWins[policies[1].getName()] = 0

        policyAssignedAsBlack[policies[0].getName()] = 0
        policyAssignedAsBlack[policies[1].getName()] = 0

        queue = DispatchQueue(label: name + "stat", attributes: .concurrent)
    }

    // Not thread safe
    func update(winner: Player?, blackPlayerPolicy: Policy, whitePlayerPolicy: Policy, moveCount: Int) {
        totalGames += 1
        totalMoves += moveCount
        policyAssignedAsBlack[blackPlayerPolicy.getName()]! += 1

        if winner == nil {
            // Nothing more to update
            return
        }

        if winner! == .BLACK {
            blackWins[blackPlayerPolicy.getName()]! += 1
            blackTotalWins += 1
        } else {
            whiteWins[whitePlayerPolicy.getName()]! += 1
            whiteTotalWins += 1
        }
    }

    func merge(_ anotherStats: PlayStats) {
        queue.sync(flags: .barrier, execute: {
            self.totalGames += anotherStats.totalGames
            self.totalMoves += anotherStats.totalMoves
            self.blackTotalWins += anotherStats.blackTotalWins
            self.whiteTotalWins += anotherStats.whiteTotalWins

            for policy in self.policies {
                let name = policy.getName()
                self.blackWins[name]! += anotherStats.blackWins[name]!
                self.whiteWins[name]! += anotherStats.whiteWins[name]!
                self.policyAssignedAsBlack[name]! += anotherStats.policyAssignedAsBlack[name]!
            }
        })
    }

    func summarize() {
        queue.sync {
            let logger = Logger()
            logger.logAndPrint("Total games: \(self.totalGames)")
            logger.logAndPrint("Total moves: \(self.totalMoves)")
            logger.logAndPrint("Total black wins: \(self.blackTotalWins)")
            logger.logAndPrint("Total white wins: \(self.whiteTotalWins)")

            for policy in self.policies {
                let name = policy.getName()
                logger.logAndPrint("For policy \(name): as black \(self.policyAssignedAsBlack[name]!), black wins \(self.blackWins[name]!), white wins \(self.whiteWins[name]!)")
            }
        }
    }
}