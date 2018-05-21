import Foundation

struct Configuration {
    var size: Int
    var numberToWin: Int
    var selfPlayTimeInSecs: Double
    var perMoveSimulationTimes: Int
    var recordStates: Bool
    var vsHuman: Bool
    var ratingStage: Bool
    var verbose: Int

    init(size: Int = 8, numberToWin: Int = 5, selfPlayTimeInSecs: Double, perMoveSimulationTimes: Int = 1600, recordStates: Bool = false, vsHuman: Bool = false, ratingStage: Bool = false, verbose: Int = 0) {
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

let configuration: Configuration

if let value = ProcessInfo.processInfo.environment["RL_TIME_IN_SECS"] {
    print("RL mode.")
    configuration = Configuration(selfPlayTimeInSecs: Double(value)!, recordStates: true)
} else if let value = ProcessInfo.processInfo.environment["RATING_TIME_IN_SECS"] {
    print("Rating mode.")
    configuration = Configuration(selfPlayTimeInSecs: Double(value)!,
                                  ratingStage: true)
} else {
    configuration = Configuration(selfPlayTimeInSecs: 3.0, vsHuman: true, verbose: 1)
}

print("Configuration:\n\(configuration)")

if configuration.ratingStage {
    selfPlaysAndRating(size: configuration.size,
                       numberToWin: configuration.numberToWin,
                       selfPlayTimeInSecs: configuration.selfPlayTimeInSecs,
                       perMoveSimulationTimes: configuration.perMoveSimulationTimes,
                       verbose: configuration.verbose)
    exit(0)
}

if !configuration.vsHuman {
    selfPlaysAndRecord(size: configuration.size,
                       numberToWin: configuration.numberToWin,
                       selfPlayTimeInSecs: configuration.selfPlayTimeInSecs,
                       perMoveSimulationTimes: configuration.perMoveSimulationTimes,
                       recordStates: configuration.recordStates,
                       verbose: configuration.verbose)
    exit(0)
}

// Play with human
playWithHuman(size: configuration.size,
              numberToWin: configuration.numberToWin,
              perMoveSimulationTimes: configuration.perMoveSimulationTimes,
              verbose: configuration.verbose)
