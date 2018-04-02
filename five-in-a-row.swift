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
class State {
  init(_ move: Move, _ previovsState: State? = nil) {
    self.currentMove = move
    self.previovsState = previovsState
  }

  var previovsState: State?
  var currentMove: Move
}

enum Player {
  case NONE, WHITE, BLACK
}

class Board {
  var states: [State]
  var moves: Set<Move>
  var size: Int

  init(_ size: Int = 8) {
    self.states = []
    self.moves = []
    self.size = size
  }

  func newMove(_ move: Move) throws {
    // FIXME: Validate the move based on history.
    self.moves.insert(move)
    if states.isEmpty {
      states.append(State(move))
    } else {
      states.append(State(move, states.last!))
    }
  }

  func contains(_ move: Move) -> Player? {
    if !self.moves.contains(move) {
      return nil
    }

    var count = 0
    for state in states {
      if state.currentMove == move {
        return count % 2 == 0 ? .BLACK: .WHITE
      }
      count += 1
    }
    return .NONE
  }

  func print() {
    for i in 0..<self.size {
      for j in 0..<self.size {
        if let player = self.contains(Move(x:i, y:j)) {
          if player == .BLACK {
            Swift.print(" \u{001B}[0;31m*\u{001B}[0;0m", terminator: "")
          } else {
            Swift.print(" \u{001B}[0;37m*\u{001B}[0;0m", terminator: "")
          }
        } else {
          Swift.print(" .", terminator: "")
        }
      }
      Swift.print("")
    }
  }
}

let board = Board()
board.newMove(Move(x:4, y:4))
board.newMove(Move(x:2, y:3))
board.print()
