import Foundation

protocol Storage {
  func save(state: State, winner: Player?)
}

class CSVStorage: Storage {
  
  let fileName: String
  let focusedPlayer: Player
  var content: String
  
  init(fileName: String, focusedPlayer: Player) {
    self.fileName = fileName
    self.focusedPlayer = focusedPlayer
  }
  
  func save(state: State, winner: Player?) {
    var result = [String]()
    if winner == focusedPlayer {
      result.append("1")
    } else {
      result.append("0")
    }
    result.append(state.toString())
  }
}
