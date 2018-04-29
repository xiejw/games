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
      let move = Move(x:x!, y:y!)
      
      if let err = validateFn(move) {
        throw err
      }
      return move
      
    } catch PlayError.invalidMove(let move, let errMsg) {
      print("The move: \(move) is invalid: \(errMsg)")
      print("Please try again!")
    } catch PlayError.invalidInput(let errMsg) {
      print("The input is invalid: \(errMsg)")
      print("Please try again!")
    } catch {
      print("Unknown error: \(error)")
    }
  }
}

func formatDate(timeIntervalSince1970: Double) -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  dateFormatter.timeZone = TimeZone.current
  
  return dateFormatter.string(from: Date(timeIntervalSince1970: timeIntervalSince1970))
}

func playWithHuman(game: Game, policy: Policy, board: Board) {
  while true {
    let nextPlayer = game.states.last!.nextPlayer
    print("Next player is \(nextPlayer)")

    var move: Move
    if nextPlayer == .WHITE {
      move = getMoveFromUser(validateFn: {(move: Move) -> Error? in
        return game.validateNewMove(move)
      })
    } else {
      let history = game.states
      let legalMoves = board.legalMoves(stateHistory: history)
      (move, _) = policy.getNextMove(stateHistory: history, legalMoves: legalMoves)
    }
    print("Push move \(move)")
    try! game.newMove(move)

    game.print()
    if let winner = board.winner(stateHistory: game.states) {
      print("We have a winner \(winner)")
      break
    }
  }
}

