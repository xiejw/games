import Foundation
import CoreML
import GameplayKit

// The wrapper class to predict distribution.
class DistributionPredictionWrapper {

  var size: Int

  // The CoreML model.
  let model = Distribution()

  init(size: Int) {
    self.size = size
  }

  func predictDistribution(state: State, nextPlayer: Player) -> [Double] {
    let mlMultiArrayInput = try? MLMultiArray(shape:[1, 8, 8], dataType:MLMultiArrayDataType.double)
    let boardState = state.boardState(size: size)
    // Flatten Board state matrix to c-style array.
    for x in 0..<size {
      for y in 0..<size {
        let value = NSNumber(floatLiteral: boardState[x][y])
        mlMultiArrayInput![x*size + y] = value
      }
    }
    
    let mlMultiInput = try? MLMultiArray(shape:[1], dataType:MLMultiArrayDataType.double)
    mlMultiInput![0] = nextPlayer == .BLACK ? 1.0 : -1.0

    let output = try! model.prediction(input:
      DistributionInput(board: mlMultiArrayInput!, next_player: mlMultiInput!))
    
    var outputs = [Double]()
    for i in 0..<size * size {
      outputs.append(Double(output.distribution[i].floatValue))
    }
    return outputs
  }
}

//protocol Predictor {
//  func predictWinningProbability(state: State) -> (black: Double, white: Double)
//}

//class RandomPredictor: Predictor {
//
//  let dice3d6 = GKGaussianDistribution(randomSource: GKRandomSource(), lowestValue: 0, highestValue: 80)
//
//  func predictWinningProbability(state: State) -> (black: Double, white: Double) {
//    let black = Double(dice3d6.nextInt()) / 100.0
//    let white = 0.8 - black
//    return (black, white)
//  }
//}
//
//// The wrapper class to predict the Black player winning probability.
//class StatePredictionWrapper: Predictor {
//
//  var size: Int
//
//  // The CoreML model.
//  let model = WinnerPredictor()
//
//  init(size: Int) {
//    self.size = size
//  }
//
//  func predictWinningProbability(state: State) -> (black: Double, white: Double) {
//    let mlMultiArrayInput = try? MLMultiArray(shape:[1, 8, 8], dataType:MLMultiArrayDataType.double)
//    let boardState = state.boardState(size: size)
//    // Flatten Board state matrix to c-style array.
//    for x in 0..<size {
//      for y in 0..<size {
//        let value = NSNumber(floatLiteral: boardState[x][y])
//        mlMultiArrayInput![x*size + y] = value
//      }
//    }
//
//    let output = try! model.prediction(input: WinnerPredictorInput(board: mlMultiArrayInput!))
//
//    // FIXME
//    let b = Double(output.black[0].floatValue)
//    let w = Double(output.white[0].floatValue)
//    return (b, w)
//  }
//}

