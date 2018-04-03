import Foundation

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
