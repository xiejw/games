// Defines all basic structure required by the game, including Move, State, Game.
import Foundation

enum Player {
    case WHITE, BLACK
}

enum PlayError: Error {
    case invalidMove(move: Move, errMsg: String)
    case invalidInput(errMsg: String)
}

class Game {
    private var states = [State]()
    private var moves = Set<Move>()
    private let size: Int
    private let numberToWin: Int

    init(size: Int = 8, numberToWin: Int = 5) {
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

        moves.insert(move)
        states.append(State(move, states.last))
    }

    func stateHistory() -> [State] {
        return states
    }
}

// Add the print() method to print the board in terminal.
extension Game {
    // Given move and state, find the player for that.
    private func playForMove(move: Move, stateHistory: [State]) -> Player {
        var count = 0
        for state in stateHistory {
            if state.currentMove == move {
                return count % 2 == 0 ? .BLACK : .WHITE
            }
            count += 1
        }
        preconditionFailure("This should never happen")
    }

    private func contains(_ move: Move) -> Player? {
        if !moves.contains(move) {
            return nil
        }
        return playForMove(move: move, stateHistory: states)
    }

    func print() {
        Swift.print(" x\\y", terminator: "")
        for i in 0 ..< size {
            if i < 10 {
                Swift.print(" \(i)", terminator: "")
            } else {
                Swift.print("\(i)", terminator: "")
            }
        }
        Swift.print("")

        for i in 0 ..< size {
            if i < 10 {
                Swift.print(" \(i)  ", terminator: "")
            } else {
                Swift.print("\(i)  ", terminator: "")
            }
            for j in 0 ..< size {
                if let player = self.contains(Move(x: i, y: j)) {
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
