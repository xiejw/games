import Foundation

protocol Predictor {
    func predictDistributionAndReward(state: State, nextPlayer: Player) -> ([Double], Double)
}

class RandomPredictor: Predictor {
    private let size: Int
    init(size: Int) {
        self.size = size
    }

    func predictDistributionAndReward(state _: State, nextPlayer _: Player) -> ([Double], Double) {
        var probabities = [Double]()
        probabities.reserveCapacity(size * size)
        for _ in 0 ..< (size * size) {
            probabities.append(1.0)
        }
        let reward = 0.0
        return (probabities, reward)
    }
}
