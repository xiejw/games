import Foundation

class MCTSBasedPolicy: Policy {
  
  let name: String
  let size: Int
  let perMoveSimulationTimes: Int
  let distributionGenerator: Predictor
  let board: Board
  let record: Bool
  let playMode: Bool
  
  init(name: String, size: Int, distributionGenerator: Predictor,
       board: Board, perMoveSimulationTimes: Int, shouldRecord: Bool = true, playMode: Bool = false) {
    self.name = name
    self.size = size
    self.board = board
    self.perMoveSimulationTimes = perMoveSimulationTimes
    self.distributionGenerator = distributionGenerator
    self.record = shouldRecord
    self.playMode = playMode
  }
  
  func getName() -> String {
    return name
  }
  
  func shouldRecord() -> Bool {
    return record
  }
  
  func getNextMove(stateHistory: [State], legalMoves: [Move]) -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
    return runSimulationsAndGetNextMove(originalStateHistory: stateHistory)
  }
  
  func runSimulationsAndGetNextMove(originalStateHistory: [State]) -> (nextMove: Move, policyUnnormalizedDistribution: [Double]) {
    // We create a new cache each time and share between all simulations.
    let nodeFactory = NodeFactory(distributionGenerator: distributionGenerator, size: size)
    
    for _ in 0..<perMoveSimulationTimes {
      var visitedNodes = [Node]()
      var selectedMoves = [Move]()
      // A new copy
      var stateHistory = originalStateHistory
      // Keep transvese until new node.
      while true {
        let legalMoves = board.legalMoves(stateHistory: stateHistory)
        var reward: Double?
        var node: Node? = nil
        var nextState: State? = nil
        
        if legalMoves.count == 0 {
          reward = 0.0
        } else {
          nextState = stateHistory.last!
          var tmpNode: Node
          (tmpNode, reward) = nodeFactory.getNextNode(state: nextState!, legalMoves: legalMoves)
          node = tmpNode
        }
        
        if reward != nil {
          for (index, visitedNode) in visitedNodes.enumerated() {
            visitedNode.backup(reward!, move: selectedMoves[index])
          }
          break
        }
        let (_, move) = node!.getNextMoveWithExploration()
        visitedNodes.append(node!)
        selectedMoves.append(move)
        stateHistory.append(board.nextState(state: nextState!, move: move))
      }
    }
    
    if playMode {
      return nodeFactory.getRootNode(originalStateHistory.last!).getBestMove()
    } else {
      return nodeFactory.getRootNode(originalStateHistory.last!).getBestMoveForPlay()
    }
  }
}
