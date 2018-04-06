import XCTest

class simulatorTest: XCTestCase {
  
  func testLegalMoves() {
    let move01 = Move(x: 0, y: 1)
    let move11 = Move(x: 1, y: 1)
    
    let state1 = State(move01)
    let state2 = State(move11, state1)
    
    let ai = GameSimulator(size: 2)
    let moves = ai.legalMoves(stateHistory: [state1, state2])
    XCTAssertEqual([Move(x: 0, y:0), Move(x: 1, y: 0)], moves)
  }
  
  func testWinnerForEmptyBoard() {
    let ai = GameSimulator(size: 4)
    let winner = ai.winner(stateHistory: [State]())
    XCTAssertNil(winner)
  }
}
