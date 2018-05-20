import XCTest

class FakePredictor: Predictor {
    let nextPlayerReward = 0.3

    func predictDistributionAndNextPlayerReward(state _: State) -> ([Double], Double) {
        return ([1.0, 2.0, 3.0, 4.0], nextPlayerReward)
    }
}

class MCTSTest: XCTestCase {
    func testNodeFactoryInitialStates() {
        let size = 2
        let board = Board(size: size)
        let nodeFactory = NodeFactory(predictor: FakePredictor(), size: size)

        let move00 = Move(x: 0, y: 0) // BLACK
        let move01 = Move(x: 0, y: 1) // WHITE

        let state0 = State(move00)
        let state1 = State(move01, state0)
        let statHistory = [state0, state1] // NEXT Player: Black

        let legalMoves = board.legalMoves(stateHistory: statHistory)
        XCTAssertEqual([Move(x: 1, y: 0), Move(x: 1, y: 1)], legalMoves)

        let (node, nextPlayerReward) = nodeFactory.getNode(by: state1, legalMoves: legalMoves)
        XCTAssertEqual(0.3, nextPlayerReward!)

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

    func testNodeFactoryAfterLearnWhenNextPlayerIsBlackPlayer() {
        let size = 2
        let board = Board(size: size)
        let nodeFactory = NodeFactory(predictor: FakePredictor(), size: size)

        let move00 = Move(x: 0, y: 0)
        let move01 = Move(x: 0, y: 1)

        let state0 = State(move00)
        let state1 = State(move01, state0)
        let statHistory = [state0, state1]

        let move10 = Move(x: 1, y: 0)
        let move11 = Move(x: 1, y: 1)

        let legalMoves = board.legalMoves(stateHistory: statHistory)
        XCTAssertEqual([move10, move11], legalMoves)

        // Basic setup.
        let (node, nextPlayerReward) = nodeFactory.getNode(by: state1, legalMoves: legalMoves)
        XCTAssertEqual(0.3, nextPlayerReward!)

        let (_, move) = node.getNextMoveWithExploration()
        XCTAssertEqual(move11, move)

        // Now learning.
        let newPlayerBlackReward = 1.0
        node.backup(blackPlayerReward: newPlayerBlackReward, move: move10)

        XCTAssertEqual(2, node.qValueTotal.count)
        XCTAssertEqual(newPlayerBlackReward, node.qValueTotal[move10]!) // Learnt
        XCTAssertEqual(0.0, node.qValueTotal[move11]!)

        XCTAssertEqual(2, node.visitCount.count)
        XCTAssertEqual(1, node.visitCount[move10]!) // Learnt
        XCTAssertEqual(0, node.visitCount[move11]!)

        // Should not change.
        XCTAssertEqual(2, node.prioryProbability.count)
        XCTAssertEqual(3.0 / 7.0, node.prioryProbability[Move(x: 1, y: 0)]!, accuracy: 0.01)
        XCTAssertEqual(4.0 / 7.0, node.prioryProbability[Move(x: 1, y: 1)]!, accuracy: 0.01)

        let (ucbValue, newBestMove) = node.getNextMoveWithExploration()
        XCTAssertEqual(move10, newBestMove)
        XCTAssertEqual(newPlayerBlackReward + 3.0 / 7.0, ucbValue)

        // Though best move is randonly sampled, as the visited count for move11 is zero, the result
        // is deterministic.
        let (bestMove, unnormalizedProb) = node.getBestMove()
        XCTAssertEqual(move10, bestMove)
        // unnormalizedProb is about the visited counts.
        XCTAssertEqual([1.0, 0.0], unnormalizedProb)
    }

    func testNodeFactoryAfterLearnWhenNextPlayerIsWhitePlayer() {
        let size = 2
        let board = Board(size: size)
        let nodeFactory = NodeFactory(predictor: FakePredictor(), size: size)

        let move00 = Move(x: 0, y: 0)

        let state0 = State(move00)
        let statHistory = [state0]

        let move01 = Move(x: 0, y: 1)
        let move10 = Move(x: 1, y: 0)
        let move11 = Move(x: 1, y: 1)

        let legalMoves = board.legalMoves(stateHistory: statHistory)
        XCTAssertEqual([move01, move10, move11], legalMoves)

        // Basic setup.
        let (node, nextPlayerReward) = nodeFactory.getNode(by: state0, legalMoves: legalMoves)
        XCTAssertEqual(0.3, nextPlayerReward!)

        let (_, move) = node.getNextMoveWithExploration()
        XCTAssertEqual(move11, move)

        // Now learning.
        let newPlayerBlackReward = 1.0
        node.backup(blackPlayerReward: newPlayerBlackReward, move: move11)

        XCTAssertEqual(3, node.qValueTotal.count)
        XCTAssertEqual(newPlayerBlackReward * -1, node.qValueTotal[move11]!) // Learnt
        XCTAssertEqual(0.0, node.qValueTotal[move10]!)
        XCTAssertEqual(0.0, node.qValueTotal[move01]!)

        XCTAssertEqual(3, node.visitCount.count)
        XCTAssertEqual(1, node.visitCount[move11]!) // Learnt
        XCTAssertEqual(0, node.visitCount[move01]!)
        XCTAssertEqual(0, node.visitCount[move10]!)

        // Should not change.
        XCTAssertEqual(3, node.prioryProbability.count)
        XCTAssertEqual(2.0 / 9.0, node.prioryProbability[Move(x: 0, y: 1)]!, accuracy: 0.01)
        XCTAssertEqual(3.0 / 9.0, node.prioryProbability[Move(x: 1, y: 0)]!, accuracy: 0.01)
        XCTAssertEqual(4.0 / 9.0, node.prioryProbability[Move(x: 1, y: 1)]!, accuracy: 0.01)

        let (ucbValue, newBestMove) = node.getNextMoveWithExploration()
        XCTAssertEqual(move10, newBestMove)
        XCTAssertEqual(3.0 / 9.0 * 2.0, ucbValue) // 2.0 is 1 + sqrt(totalCount)

        // Though best move is randonly sampled, as the visited count for move11 is zero, the result
        // is deterministic.
        let (bestMove, unnormalizedProb) = node.getBestMove()
        XCTAssertEqual(move11, bestMove)
        // unnormalizedProb is about the visited counts.
        XCTAssertEqual([0.0, 0.0, 1.0], unnormalizedProb)
    }

    func testNodeFactoryWithEnforcedExploreUnvistedNodes() {
        let size = 2
        let board = Board(size: size)
        let nodeFactory = NodeFactory(predictor: FakePredictor(), size: size, enforceExploreUnvisitedMoves: true)

        let move00 = Move(x: 0, y: 0)
        let move01 = Move(x: 0, y: 1)

        let state0 = State(move00)
        let state1 = State(move01, state0)
        let statHistory = [state0, state1]

        let move10 = Move(x: 1, y: 0)
        let move11 = Move(x: 1, y: 1)

        let legalMoves = board.legalMoves(stateHistory: statHistory)
        XCTAssertEqual([move10, move11], legalMoves)

        // Basic setup.
        let (node, nextPlayerReward) = nodeFactory.getNode(by: state1, legalMoves: legalMoves)
        XCTAssertEqual(0.3, nextPlayerReward!)

        let (_, move) = node.getNextMoveWithExploration()
        XCTAssertNotEqual(move00, move)
        XCTAssertNotEqual(move01, move)

        // Now learning.
        let newPlayerBlackReward = 100.0
        node.backup(blackPlayerReward: newPlayerBlackReward, move: move10)

        XCTAssertEqual(2, node.qValueTotal.count)
        XCTAssertEqual(newPlayerBlackReward, node.qValueTotal[move10]!) // Learnt
        XCTAssertEqual(0.0, node.qValueTotal[move11]!)

        XCTAssertEqual(2, node.visitCount.count)
        XCTAssertEqual(1, node.visitCount[move10]!) // Learnt
        XCTAssertEqual(0, node.visitCount[move11]!)

        // Should not change.
        XCTAssertEqual(2, node.prioryProbability.count)
        XCTAssertEqual(3.0 / 7.0, node.prioryProbability[Move(x: 1, y: 0)]!, accuracy: 0.01)
        XCTAssertEqual(4.0 / 7.0, node.prioryProbability[Move(x: 1, y: 1)]!, accuracy: 0.01)

        // Even the move 10 has super large value, move11 has not been visited. So, it must be selected here.
        let (ucbValue, newBestMove) = node.getNextMoveWithExploration()
        XCTAssertEqual(move11, newBestMove)
        XCTAssertEqual(Node.unvisitedMoveValue, ucbValue)

        // Though best move is randonly sampled, as the visited count for move11 is zero, the result
        // is deterministic.
        let (bestMove, unnormalizedProb) = node.getBestMove()
        XCTAssertEqual(move10, bestMove)
        // unnormalizedProb is about the visited counts.
        XCTAssertEqual([1.0, 0.0], unnormalizedProb)
    }
}
