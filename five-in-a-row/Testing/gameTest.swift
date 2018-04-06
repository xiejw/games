import XCTest

class BoardTest : XCTestCase {
  
  func testMoveEquality() {
    let move1 = Move(x: 2, y: 3)
    let move2 = Move(x: 2, y: 3)
    XCTAssertTrue(move1 == move2)
    
    let move3 = Move(x: 3, y: 2)
    XCTAssertFalse(move1 == move3)
  }
  
  func testStateEquality() {
    let move23 = Move(x: 2, y: 3)
    let move33 = Move(x: 3, y: 3)
    let move43 = Move(x: 4, y: 3)
    
    // Black 2 3
    var state1 = State(move23)
    // White 3 3
    state1 = State(move33, state1)
    // Black 4 3
    state1 = State(move43, state1)
  
    // state2 is same as state1 but swapping the move1 and move3.
    // They both represent the black. So, state1 == state2
    // Black 4 3
    var state2 = State(move43)
    // White 3 3
    state2 = State(move33, state2)
    // Black 2 3
    state2 = State(move23, state2)
    XCTAssertTrue(state1 == state2)
    
    // Swapping move1 and move2 are not ok as the colors are different.
    // Black 3 3
    var state3 = State(move33)
    // White 2 3
    state3 = State(move23, state3)
    // Black 4 3
    state3 = State(move43, state3)
    XCTAssertFalse(state1 == state3)
  }
  
  func testStatePlayer() {
    let move23 = Move(x: 2, y: 3)
    let move33 = Move(x: 3, y: 3)
    let move43 = Move(x: 4, y: 3)
    
    var state = State(move23)
    state = State(move33, state)
    state = State(move43, state)
    XCTAssertEqual(Player.BLACK, state.currentPlayer)
    XCTAssertEqual(Player.WHITE, state.nextPlayer)
  }
}
