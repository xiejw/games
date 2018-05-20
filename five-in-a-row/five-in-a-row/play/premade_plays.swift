// A premade set to test the basic results on very small problems.
import Foundation

func premadePlay1() {
    let size = 3
    let numberToWin = 3
    let game = Game(size: size, numberToWin: numberToWin)
    let board = Board(size: size, numberToWin: numberToWin)

    try! game.newMove(Move(x: 2, y: 0)) // B
    try! game.newMove(Move(x: 1, y: 0)) // W
    try! game.newMove(Move(x: 2, y: 1)) // B
    try! game.newMove(Move(x: 0, y: 2)) // W
    try! game.newMove(Move(x: 0, y: 0)) // B
    game.print()

    let policyToPlay = MCTSBasedPolicy(
        name: "mcts",
        size: size,
        predictor: RandomPredictor(size: size),
        board: board,
        perMoveSimulationTimes: 1600, shouldRecord: false, playMode: true, verbose: 1)

    var history = game.stateHistory()
    var legalMoves = board.legalMoves(stateHistory: history)
    var (move, _) = policyToPlay.getNextMove(stateHistory: history, legalMoves: legalMoves)
    precondition(move == Move(x: 2, y: 2), "The system must be wrong.")
    print("Push move \(move)")
    try! game.newMove(move)
    game.print()

    try! game.newMove(Move(x: 1, y: 1))

    history = game.stateHistory()
    legalMoves = board.legalMoves(stateHistory: history)
    (move, _) = policyToPlay.getNextMove(stateHistory: history, legalMoves: legalMoves)
    precondition(move == Move(x: 1, y: 2), "The system must be wrong.")
    print("Push move \(move)")
    try! game.newMove(move)
    game.print()
}
