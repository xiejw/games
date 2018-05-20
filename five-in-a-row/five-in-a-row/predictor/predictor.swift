import Foundation

protocol Predictor {
    // Give the distribution of the next move and the expected reward of "next player".
    // Here, the "next player" is simply state.nextPlayer, i.e., the player is going to play
    // the next move. So, reward and the distribution is the consistent. The reward has value
    // between [-1, 1]. Durning ANN training, it could be a sigmold * 2 - 1.
    func predictDistributionAndNextPlayerReward(state: State) -> ([Double], Double)
}

class RandomPredictor: Predictor {
    private let size: Int
    init(size: Int) {
        self.size = size
    }

    func predictDistributionAndNextPlayerReward(state _: State) -> ([Double], Double) {
        var probabities = [Double]()
        probabities.reserveCapacity(size * size)
        for _ in 0 ..< (size * size) {
            probabities.append(1.0)
        }

        // +- 0.05
        let reward = 0.0 + (Double(random(100)) - 50.0) / 1000.0
        return (probabities, reward)
    }
}
