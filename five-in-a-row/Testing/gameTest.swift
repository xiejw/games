import XCTest

class GameTest: XCTestCase {
    func testGameAddMovesSuccesfully() {
        let game = Game(size: 2, numberToWin: 2)
        try! game.newMove(Move(x: 0, y: 0))
        try! game.newMove(Move(x: 0, y: 1))
        try! game.newMove(Move(x: 1, y: 0))
        try! game.newMove(Move(x: 1, y: 1))
    }

    func testGameAddInvalidMove() {
        let game = Game(size: 2, numberToWin: 2)
        let move = Move(x: 1, y: 1)
        try! game.newMove(move)
        XCTAssertTrue(game.validateNewMove(move) != nil)

        do {
            try game.newMove(move)
            XCTFail("Should not be OK.")
        } catch PlayError.invalidMove {
            // Expected.
        } catch {
            XCTFail("Should not see this error.")
        }
    }

    func testStateHistory() {
        let game = Game(size: 2, numberToWin: 2)
        try! game.newMove(Move(x: 0, y: 0))
        try! game.newMove(Move(x: 0, y: 1))

        let state1 = State(Move(x: 0, y: 0))
        let state2 = State(Move(x: 0, y: 1), state1)

        let states = game.stateHistory()
        XCTAssertEqual([state1, state2], states)
    }
}
