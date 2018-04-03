import Foundation

// Represents the current move.
struct Move: Hashable {
  var x: Int
  var y: Int
  
  var hashValue: Int {
    return x.hashValue * 16 + y.hashValue
  }
  
  static func ==(lhs: Move, rhs: Move) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
  }
}

// A chain based State with current move and previous State. It is cheap to make
// copy.
class State: Hashable {
  init(_ move: Move, _ previovsState: State? = nil) {
    self.currentMove = move
    self.previovsState = previovsState
  }
  
  var previovsState: State?
  var currentMove: Move
  
  var hashValue: Int {
    return currentMove.hashValue
  }
  
  static func ==(lhs: State, rhs: State) -> Bool {
    return lhs.currentMove == rhs.currentMove && lhs.previovsState == rhs.previovsState
  }
}

enum Player {
  case NONE, WHITE, BLACK
}

enum PlayError: Error {
  case invalidMove(move: Move)
}

class Board {
  var states: [State]
  var moves: Set<Move>
  let size: Int
  let numberToWin: Int
  
  init(size: Int = 8, numberToWin: Int = 5) {
    self.states = []
    self.moves = []
    self.size = size
    self.numberToWin = numberToWin
  }
  
  func newMove(_ move: Move) throws {
    if moves.contains(move) {
      throw PlayError.invalidMove(move: move)
    }
    
    self.moves.insert(move)
    if states.isEmpty {
      states.append(State(move))
    } else {
      states.append(State(move, states.last!))
    }
  }
  
  // Given move and state, find the player for that.
  func playForMove(move: Move, stateHistory: [State]) -> Player {
    var count = 0
    for state in stateHistory {
      if state.currentMove == move {
        return count % 2 == 0 ? .BLACK: .WHITE
      }
      count += 1
    }
    assertionFailure("This should never happen")
    return .NONE
  }
  
  func contains(_ move: Move) -> Player? {
    if !self.moves.contains(move) {
      return nil
    }
    return playForMove(move: move, stateHistory: states)
  }
  
  func print() {
    
    Swift.print("x\\y", terminator: "")
    for i in 0..<self.size {
      Swift.print(" \(i)", terminator: "")
    }
    Swift.print("")
    
    for i in 0..<self.size {
      Swift.print("\(i)  ", terminator: "")
      for j in 0..<self.size {
        if let player = self.contains(Move(x:i, y:j)) {
          if player == .BLACK {
            Swift.print(" *", terminator: "")
          } else {
            Swift.print(" O", terminator: "")
          }
        } else {
          Swift.print(" .", terminator: "")
        }
      }
      Swift.print("")
    }
  }
}

