import CoreML
import Foundation

// The wrapper class to predict distribution and reward.
class DistributionPredictionWrapper: Predictor {
    private var size: Int

    // The CoreML model.
    private let model = Distribution()

    init(size: Int) {
        self.size = size
    }

    func predictDistributionAndNextPlayerReward(state: State) -> ([Double], Double) {
        let nextPlayer = state.nextPlayer
        let mlMultiArrayInput = try? MLMultiArray(shape: [1, 8, 8], dataType: MLMultiArrayDataType.double)
        let boardState = state.boardState(size: size)
        // Flatten Board state matrix to c-style array.
        for x in 0 ..< size {
            for y in 0 ..< size {
                let value = NSNumber(floatLiteral: boardState[x][y])
                mlMultiArrayInput![x * size + y] = value
            }
        }

        let mlMultiInput = try? MLMultiArray(shape: [1], dataType: MLMultiArrayDataType.double)
        mlMultiInput![0] = nextPlayer == .BLACK ? 1.0 : -1.0

        let output = try! model.prediction(input:
            DistributionInput(board: mlMultiArrayInput!, next_player: mlMultiInput!))

        var outputs = [Double]()
        for i in 0 ..< size * size {
            outputs.append(Double(output.distribution[i].floatValue))
        }

        let reward = Double(output.reward[0].floatValue)
        return (outputs, reward)
    }
}
