import Foundation

// Represents the current move.
struct Move: Hashable, Equatable {
  var x: Int
  var y: Int
  
  var hashValue: Int {
    return x.hashValue * 31 + y.hashValue
  }
  
  static func ==(lhs: Move, rhs: Move) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
  }
  
  // The < operator is used to sort the Moves in a Game.
  // Five-in-a-row does not allow Player to take the stone out.
  // So, we do not need to sort based on Player.
  static func <(lhs: Move, rhs: Move) -> Bool {
    if lhs.x < rhs.x {
      return true
    } else if lhs.x > rhs.x {
      return false
    }
    return lhs.y < rhs.y
  }
}

// Represents a Stone on Board.
fileprivate struct Stone: Equatable {
  var move: Move
  var player: Player
  
  // Used to sort the Move only
  static func <(lhs: Stone, rhs: Stone) -> Bool {
    return lhs.move < rhs.move
  }
  
  static func ==(lhs: Stone, rhs: Stone) -> Bool {
    return lhs.player == rhs.player && lhs.move == rhs.move
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
  
  lazy var currentPlayer: Player = {
    if previovsState == nil {
      return .BLACK
    }
    return (previovsState!.currentPlayer == .WHITE) ? .BLACK : .WHITE
  }()
  
  lazy var nextPlayer: Player = {
    return (currentPlayer == .WHITE) ? .BLACK : .WHITE
  }()
  
  // The rest of the code is all about hashing.
  fileprivate var hashTable = [Stone]()
  fileprivate var lazyHashValue = 0
  
  func lazyBuildHashTable() {
    // We can take the prevousState.hashTable and insert.
    if !hashTable.isEmpty {
      return
    }

    hashTable.append(Stone(move: currentMove, player: currentPlayer))
    
    var state = previovsState
    while state != nil {
      let move = state!.currentMove
      hashTable.append(Stone(move:move, player:state!.currentPlayer))
      state = state!.previovsState
    }
    
    hashTable.sort(by: <)
    
    for stone in hashTable[0..<min(5, hashTable.count)] {
      lazyHashValue *= 256
      lazyHashValue += stone.move.hashValue
    }
  }
  
  var hashValue: Int {
    lazyBuildHashTable()
    return lazyHashValue
  }
  
  static func ==(lhs: State, rhs: State) -> Bool {
    if lhs.hashValue != rhs.hashValue {
      return false
    }
    return lhs.hashTable == rhs.hashTable
  }
}

enum Player {
  case NONE, WHITE, BLACK
}

enum PlayError: Error {
  case invalidMove(move: Move, errMsg: String)
  case invalidInput(errMsg: String)
}

class Game {
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
  
  func validateNewMove(_ move: Move) -> Error? {
    if moves.contains(move) {
      return PlayError.invalidMove(move: move, errMsg: "Duplicated move.")
    }
    if move.x < 0 || move.x >= size || move.y < 0 || move.y >= size {
      return PlayError.invalidMove(move: move, errMsg: "Out of range.")
    }
    return nil
  }
  
  func newMove(_ move: Move) throws {
    if let err = validateNewMove(move) {
      throw err
    }

    self.moves.insert(move)
    if states.isEmpty {
      states.append(State(move))
    } else {
      states.append(State(move, states.last!))
    }
  }
  
  // Given move and state, find the player for that.
  internal func playForMove(move: Move, stateHistory: [State]) -> Player {
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
  
  internal func contains(_ move: Move) -> Player? {
    if !self.moves.contains(move) {
      return nil
    }
    return playForMove(move: move, stateHistory: states)
  }
  
  func print() {
    
    Swift.print(" x\\y", terminator: "")
    for i in 0..<self.size {
      if i < 10 {
        Swift.print(" \(i)", terminator: "")
      } else {
        Swift.print("\(i)", terminator: "")
      }
    }
    Swift.print("")
    
    for i in 0..<self.size {
      if i < 10 {
        Swift.print(" \(i)  ", terminator: "")
      } else {
        Swift.print("\(i)  ", terminator: "")
      }
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

