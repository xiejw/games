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

enum PlayError: Error {
  case invalidMove(move: Move)
}

class Board {
  var states: [State]
  var moves: Set<Move>
  let size: Int
  let numberToWin: Int
  
  init(_ size: Int = 8, numberToWin: Int = 5) {
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

class BoardSimulator {
  let size: Int
  let numberToWin: Int
  
  init(size: Int, numberToWin: Int = 5) {
    self.size = size
    self.numberToWin = numberToWin
  }
  
  func nextPlayer(state: State) -> Player {
    var count = 0
    var current_state = state
    while true {
      if current_state.previovsState != nil {
        current_state = current_state.previovsState!
        count += 1
        continue
      }
      break
    }
    return count % 2 == 1 ? .BLACK: .WHITE
  }
  
  func nextState(state: State, move: Move) -> State {
    return State(move, state)
  }
  
  func legalMoves(stateHistory: [State]) -> [Move] {
    var moves = [Move]()
    
    var existedMoves = Set<Move>()
    for state in stateHistory {
      existedMoves.insert(state.currentMove)
    }
    
    for i in 0..<self.size {
      for j in 0..<self.size {
        let move = Move(x:i, y:j)
        if existedMoves.contains(move) {
          continue
        }
        moves.append(move)
      }
    }
    return moves
  }
  
  // Given the stateHistory, return the winner.
  func winner(stateHistory: [State]) -> Player? {
    if stateHistory.isEmpty {
      return nil
    }
    
    var existedMoves = Set<Move>()
    var playerForMove = Dictionary<Move, Player>()
    for (index, state) in stateHistory.enumerated() {
      existedMoves.insert(state.currentMove)
      playerForMove[state.currentMove] = (index % 2 == 0) ? .BLACK : .WHITE
    }
    
    // With existedMoves and playerForMove, we can calcuate the Player for
    // each Move efficiently.
    func getPlayer(move: Move) -> Player {
      if !existedMoves.contains(move) {
        return .NONE
      }
      return playerForMove[move]!
    }
    
    // Check whether currentPlayer is winner.
    let currentPlayer = (stateHistory.count % 2 == 1) ? Player.BLACK : Player.WHITE
    
    // Utility funciton to check whether a line contains to the currentPlayer.
    func checkWiner(line: (Int) -> Move) -> Bool {
      for k in 1 ..< self.numberToWin {
        let newMove = line(k)
        if getPlayer(move: newMove) != currentPlayer {
          break
        }
        if k == self.numberToWin - 1 {
          return true
        }
      }
      return false
    }
    
    for i in 0..<self.size {
      for j in 0..<self.size {
        let move = Move(x:i, y:j)
        
        if getPlayer(move: move) != currentPlayer {
          continue
        }
        
        // Checking four directions is enough.
        
        // Go Right
        if checkWiner(line: { (k: Int) -> Move in return Move(x:i, y:k+j)}) {
          return currentPlayer
        }
        // Go Down
        if checkWiner(line: { (k: Int) -> Move in return Move(x:i+k, y:j)}) {
          return currentPlayer
        }
        // Go Left-Down
        if checkWiner(line: { (k: Int) -> Move in return Move(x:i+k, y:j-k)}) {
          return currentPlayer
        }
        // Go Right-Down
        if checkWiner(line: { (k: Int) -> Move in return Move(x:i+k, y:j+k)}) {
          return currentPlayer
        }
      }
    }
    return nil
  }
}
