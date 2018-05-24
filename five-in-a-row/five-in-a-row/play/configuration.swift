import Foundation

struct Configuration {
    var size: Int
    var numberToWin: Int
    var selfPlayTimeInSecs: Double?
    var perMoveSimulationTimes: Int
    var recordStates: Bool
    var vsHuman: Bool
    var ratingStage: Bool
    var verbose: Int

    init(size: Int = 8, numberToWin: Int = 5, selfPlayTimeInSecs: Double? = nil, perMoveSimulationTimes: Int = 1600, recordStates: Bool = false, vsHuman: Bool = false, ratingStage: Bool = false, verbose: Int = 0) {
        self.size = size
        self.numberToWin = numberToWin
        self.selfPlayTimeInSecs = selfPlayTimeInSecs
        self.perMoveSimulationTimes = perMoveSimulationTimes
        self.recordStates = recordStates
        self.vsHuman = vsHuman
        self.ratingStage = ratingStage
        self.verbose = verbose
    }
}
