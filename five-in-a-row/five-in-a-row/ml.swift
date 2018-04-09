import Foundation
import CoreML

class StatePredictionWrapper {
  
  var size: Int
  
  init(size: Int) {
    self.size = size
  }

  let model = board()
  
  func predictBlackPlayerWinning(state: State) -> Double {
    do {
      let mlMultiArrayInput = try? MLMultiArray(shape:[1, 8, 8], dataType:MLMultiArrayDataType.double)
      let boardState = state.boardState(size: size)
      for x in 0..<size {
        for y in 0..<size {
          let value = NSNumber(floatLiteral: boardState[x][y])
          mlMultiArrayInput![x*size + y] = value
        }
      }
      
      let output = try model.prediction(input: boardInput(board: mlMultiArrayInput!))
      return Double(output.prob[0].floatValue)
    }
    catch let error {
      print(error)
    }
    return -1
  }
}
