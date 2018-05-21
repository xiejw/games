import Foundation

// Represents the current move.
struct Move: Hashable, Equatable {
    var x: Int
    var y: Int

    var hashValue: Int {
        return x.hashValue * 31 + y.hashValue
    }

    static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    // The < operator is used to sort the Moves in a Game.
    // Five-in-a-row does not allow Player to take the stone out.
    // So, we do not need to sort based on Player.
    static func < (lhs: Move, rhs: Move) -> Bool {
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
    static func < (lhs: Stone, rhs: Stone) -> Bool {
        return lhs.move < rhs.move
    }

    static func == (lhs: Stone, rhs: Stone) -> Bool {
        return lhs.player == rhs.player && lhs.move == rhs.move
    }
}

// The base structure of the State.
// A chain based State with current move and previous State. It is cheap to make copy.
class BaseState {
    init(_ move: Move, _ previovsState: State? = nil) {
        currentMove = move
        self.previovsState = previovsState
    }

    var previovsState: State?
    var currentMove: Move

    lazy var currentPlayer: Player = {
        if previovsState == nil {
            return .BLACK // Black alway first.
        }
        return (previovsState!.currentPlayer == .WHITE) ? .BLACK : .WHITE
    }()

    lazy var nextPlayer: Player = {
        (currentPlayer == .WHITE) ? .BLACK : .WHITE
    }()
}

class State: BaseState, Hashable {
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
            hashTable.append(Stone(move: move, player: state!.currentPlayer))
            state = state!.previovsState
        }

        // in place sort.
        hashTable.sort(by: <)

        for stone in hashTable[0 ..< hashTable.count] {
            lazyHashValue *= 255
            lazyHashValue += stone.move.hashValue
            lazyHashValue = lazyHashValue % 65123
        }
    }

    lazy var hashValue: Int = {
        lazyBuildHashTable()
        return lazyHashValue
    }()

    static func == (lhs: State, rhs: State) -> Bool {
        if lhs.hashValue != rhs.hashValue {
            return false
        }
        return lhs.hashTable == rhs.hashTable
    }

    // The rest is about serialization.  // NEED Examine.
    // TODO(xiejw): Can we move it out?
    var _boardState: [[Double]]?

    func boardState(size: Int) -> [[Double]] {
        if _boardState != nil {
            return _boardState!
        }
        lazyBuildHashTable()
        var result = [[Double]]()
        result.reserveCapacity(size)
        for _ in 0 ..< size {
            var currentRow = [Double]()
            for _ in 0 ..< size {
                currentRow.append(0.0)
            }
            result.append(currentRow)
        }
        for stone in hashTable {
            // This should match the ML model.
            result[stone.move.x][stone.move.y] = stone.player == .BLACK ? 1.0 : -1.0
        }
        _boardState = result
        return result
    }
}

// Write state to I/O disk.
extension State {
    func toString() -> String {
        lazyBuildHashTable()
        var str = [String]()
        for stone in hashTable {
            str.append(String(stone.move.x))
            str.append(String(stone.move.y))
            str.append(String(stone.player == .BLACK ? 1 : 0))
        }
        return str.joined(separator: ",")
    }
}
