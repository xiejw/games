//
//  board.swift
//  five-in-a-row
//
//  Created by Jianwei Xie on 4/2/18.
//  Copyright © 2018 Jianwei Xie. All rights reserved.
//

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
  var size: Int
  
  init(_ size: Int = 8) {
    self.states = []
    self.moves = []
    self.size = size
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
  var size: Int
  
  init(size: Int) {
    self.size = size
  }
  
  func next_player(state: State) -> Player {
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
  
  func next_state(state: State, move: Move) -> State {
    return State(move, state)
  }
  
  func legal_moves(state_history: [State]) -> [Move] {
    var moves = [Move]()
    
    var existed_moves = Set<Move>()
    for state in state_history {
      existed_moves.insert(state.currentMove)
    }
    
    for i in 0..<self.size {
      for j in 0..<self.size {
        let move = Move(x:i, y:j)
        if existed_moves.contains(move) {
          continue
        }
        moves.append(move)
      }
    }
    return moves
  }
  
  func winner(state_history: [State]) -> Player? {
    // TODO
    return nil
  }
}
