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
    /*
     x\y 0 1 2
     0   * . O
     1   O . .
     2   * * .
     */
    game.print()

    let policyToPlay = MCTSBasedPolicy(
        name: "mcts",
        size: size,
        predictor: RandomPredictor(size: size),
        board: board,
        perMoveSimulationTimes: 1600, playMode: true, verbose: 1)

    var history = game.stateHistory()
    var legalMoves = board.legalMoves(stateHistory: history)
    var (move, _) = policyToPlay.getNextMove(stateHistory: history, legalMoves: legalMoves)
    precondition(move == Move(x: 2, y: 2), "The system must be wrong.")
    print("Push move \(move)")
    try! game.newMove(move)
    game.print()

    try! game.newMove(Move(x: 1, y: 1))
    /*
     x\y 0 1 2
     0   * . O
     1   O . .
     2   * * O
     */
    history = game.stateHistory()
    legalMoves = board.legalMoves(stateHistory: history)
    (move, _) = policyToPlay.getNextMove(stateHistory: history, legalMoves: legalMoves)
    precondition(move == Move(x: 1, y: 2), "The system must be wrong.")
    print("Push move \(move)")
    try! game.newMove(move)
    game.print()
}

func premadePlay2() {
    let size = 4
    let numberToWin = 3
    let game = Game(size: size, numberToWin: numberToWin)
    let board = Board(size: size, numberToWin: numberToWin)

    try! game.newMove(Move(x: 1, y: 1)) // B
    try! game.newMove(Move(x: 2, y: 1)) // W
    try! game.newMove(Move(x: 1, y: 2)) // B
    game.print()

    let policyToPlay = MCTSBasedPolicy(
        name: "mcts",
        size: size,
        predictor: RandomPredictor(size: size),
        board: board,
        perMoveSimulationTimes: 1600, playMode: true, verbose: 1)

    var history = game.stateHistory()
    var legalMoves = board.legalMoves(stateHistory: history)
    var (move, _) = policyToPlay.getNextMove(stateHistory: history, legalMoves: legalMoves)
    print("Push move \(move)")
    precondition(move == Move(x: 1, y: 0) || move == Move(x: 1, y: 3), "The system must be wrong.")
    let nextMove = move == Move(x: 1, y: 0) ? Move(x: 1, y: 3) : Move(x: 1, y: 0)

    try! game.newMove(move)
    game.print()

    history = game.stateHistory()
    legalMoves = board.legalMoves(stateHistory: history)
    (move, _) = policyToPlay.getNextMove(stateHistory: history, legalMoves: legalMoves)
    precondition(move == nextMove, "The system must be wrong.")
    print("Push move \(move)")
    try! game.newMove(move)
    game.print()
}

func premadePlay3() {
    let size = 4
    let numberToWin = 4
    let game = Game(size: size, numberToWin: numberToWin)
    let board = Board(size: size, numberToWin: numberToWin)

    try! game.newMove(Move(x: 1, y: 1)) // B
    try! game.newMove(Move(x: 2, y: 1)) // W
    try! game.newMove(Move(x: 1, y: 2)) // B
    game.print()

    let policyToPlay = MCTSBasedPolicy(
        name: "mcts",
        size: size,
        predictor: RandomPredictor(size: size),
        board: board,
        perMoveSimulationTimes: 1600, playMode: true, verbose: 1) // 3600 works

    let history = game.stateHistory()
    let legalMoves = board.legalMoves(stateHistory: history)
    let (move, _) = policyToPlay.getNextMove(stateHistory: history, legalMoves: legalMoves)
    print("Push move \(move)")

    try! game.newMove(move)
    game.print()
}
