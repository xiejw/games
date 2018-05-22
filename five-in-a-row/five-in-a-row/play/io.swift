import Foundation

func getMoveFromUser(validateFn: (Move) -> Error?) -> Move {
    while true {
        do {
            print("x: ", terminator: "")
            let x = Int(readLine()!)
            if x == nil {
                throw PlayError.invalidInput(errMsg: "coordinate must be Int")
            }
            print("y: ", terminator: "")
            let y = Int(readLine()!)
            if y == nil {
                throw PlayError.invalidInput(errMsg: "coordinate must be Int")
            }
            let move = Move(x: x!, y: y!)

            if let err = validateFn(move) {
                throw err
            }
            return move

        } catch let PlayError.invalidMove(move, errMsg) {
            print("The move: \(move) is invalid: \(errMsg)")
            print("Please try again!")
        } catch let PlayError.invalidInput(errMsg) {
            print("The input is invalid: \(errMsg)")
            print("Please try again!")
        } catch {
            print("Unknown error: \(error)")
        }
    }
}