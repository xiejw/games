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
  
  func testNoWinnerForEmptyBoard() {
    let ai = GameSimulator(size: 4)
    let winner = ai.winner(stateHistory: [State]())
    XCTAssertNil(winner)
  }
  
  func testNoWinner() {
    let move01 = Move(x: 0, y: 0) // BLACK
    let move11 = Move(x: 1, y: 1) // WHITE
    let move02 = Move(x: 0, y: 2) // BLACK
    
    let state1 = State(move01)
    let state2 = State(move11, state1)
    let state3 = State(move02, state2)
    
    let ai = GameSimulator(size: 4, numberToWin: 2)
    let winner = ai.winner(stateHistory: [state1, state2, state3])
    XCTAssertNil(winner)
  }
  
  func testHorizontalWinner() {
    let move01 = Move(x: 0, y: 1) // BLACK
    let move11 = Move(x: 1, y: 1) // WHITE
    let move02 = Move(x: 0, y: 2) // BLACK
    
    let state1 = State(move01)
    let state2 = State(move11, state1)
    let state3 = State(move02, state2)
    
    let ai = GameSimulator(size: 4, numberToWin: 2)
    let winner = ai.winner(stateHistory: [state1, state2, state3])
    XCTAssertEqual(Player.BLACK, winner)
  }
  
  func testVerticalWinner() {
    let move01 = Move(x: 0, y: 1) // BLACK
    let move11 = Move(x: 1, y: 1) // WHITE
    let move02 = Move(x: 0, y: 3) // BLACK
    let move21 = Move(x: 2, y: 1) // WHITE
    
    let state1 = State(move01)
    let state2 = State(move11, state1)
    let state3 = State(move02, state2)
    let state4 = State(move21, state3)
    
    let ai = GameSimulator(size: 4, numberToWin: 2)
    let winner = ai.winner(stateHistory: [state1, state2, state3, state4])
    XCTAssertEqual(Player.WHITE, winner)
  }
  
  func testRightDownDiagnalWinner() {
    let move01 = Move(x: 0, y: 1) // BLACK
    let move11 = Move(x: 1, y: 1) // WHITE
    let move02 = Move(x: 0, y: 3) // BLACK
    let move22 = Move(x: 2, y: 2) // WHITE
    
    let state1 = State(move01)
    let state2 = State(move11, state1)
    let state3 = State(move02, state2)
    let state4 = State(move22, state3)
    
    let ai = GameSimulator(size: 4, numberToWin: 2)
    let winner = ai.winner(stateHistory: [state1, state2, state3, state4])
    XCTAssertEqual(Player.WHITE, winner)
  }
  
  func testLeftDownDiagnalWinner() {
    let move01 = Move(x: 0, y: 1) // BLACK
    let move11 = Move(x: 1, y: 1) // WHITE
    let move02 = Move(x: 0, y: 3) // BLACK
    let move22 = Move(x: 2, y: 0) // WHITE
    
    let state1 = State(move01)
    let state2 = State(move11, state1)
    let state3 = State(move02, state2)
    let state4 = State(move22, state3)
    
    let ai = GameSimulator(size: 4, numberToWin: 2)
    let winner = ai.winner(stateHistory: [state1, state2, state3, state4])
    XCTAssertEqual(Player.WHITE, winner)
  }
}
