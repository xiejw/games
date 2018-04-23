import XCTest

class FakePredictor: Predictor {
  func predictDistributionAndReward(state: State, nextPlayer: Player) -> ([Double], Double) {
    return ([1.0, 2.0, 3.0, 4.0], 0.3)
  }
}

class MCTSTest: XCTestCase {
  
  func testNodeFactory() {
    let size = 2
    let board = Board(size: size)
    let nodeFactory = NodeFactory(distributionGenerator: FakePredictor(), size: size)
    
    let move00 = Move(x: 0, y: 0)
    let move01 = Move(x: 0, y: 1)
    
    let state0 = State(move00)
    let state1 = State(move01, state0)
    let statHistory = [state0, state1]
    
    let legalMoves = board.legalMoves(stateHistory: statHistory)
    XCTAssertEqual([Move(x: 1, y: 0), Move(x: 1, y: 1)], legalMoves)
    
    let (node, reward) = nodeFactory.getNextNode(state: state1, legalMoves: legalMoves)
    XCTAssertEqual(0.3, reward!)
    
    XCTAssertEqual(2, node.qValueTotal.count)
    for (_, value) in node.qValueTotal {
      XCTAssertEqual(0.0, value)
    }
    
    XCTAssertEqual(2, node.visitCount.count)
    for (_, count) in node.visitCount {
      XCTAssertEqual(0, count)
    }
    
    XCTAssertEqual(2, node.prioryProbability.count)
    XCTAssertEqual(3.0 / 7.0, node.prioryProbability[Move(x: 1, y: 0)]!, accuracy: 0.01)
    XCTAssertEqual(4.0 / 7.0, node.prioryProbability[Move(x: 1, y: 1)]!, accuracy: 0.01)
    
    let (ucbValue, move) = node.getNextMoveWithExploration()
    // As there is no reward leart yet, it depends on the priory probability.
    XCTAssertEqual(Move(x: 1, y: 1), move)
    XCTAssertEqual(4.0 / 7.0, ucbValue)
  }
}

