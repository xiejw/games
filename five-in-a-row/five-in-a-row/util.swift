import Foundation

func sampleFromProbabilities(probabilities: [Double]) -> Int {
    var pmf = [Double]()
    var currentSum = 0.0
    for prob in probabilities {
        currentSum += prob
        pmf.append(currentSum)
    }

    let sampleSpace: UInt32 = 10000
    let sample = Int(arc4random_uniform(sampleSpace))

    for i in 0 ..< probabilities.count {
        if Double(sample) / Double(sampleSpace) * currentSum < pmf[i] {
            return i
        }
    }
    return probabilities.count - 1
}

func randomMove(moves: [Move]) -> Move {
    let n = Int(arc4random_uniform(UInt32(moves.count)))
    return moves[n]
}

func random(_ total: Int) -> Int {
    return Int(arc4random_uniform(UInt32(total)))
}

func formatDate(timeIntervalSince1970: Double) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone.current

    return dateFormatter.string(from: Date(timeIntervalSince1970: timeIntervalSince1970))
}

func randomPermutation(policies: [Policy]) -> (Policy, Policy) {
    precondition(policies.count == 2)
    let n = Int(arc4random_uniform(100))
    if n < 50 {
        return (policies[0], policies[1])
    } else {
        return (policies[1], policies[0])
    }
}
