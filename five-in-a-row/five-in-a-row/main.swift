import Foundation

struct Configuration {
    var size: Int
    var numberToWin: Int
    var selfPlayTimeInSecs: Double
    var perMoveSimulationTimes: Int
    var recordStates: Bool
    var verbose: Int = 0
}

let configuration = Configuration(size: 8,
                                  numberToWin: 5,
                                  selfPlayTimeInSecs: 2400.0,
                                  perMoveSimulationTimes: 1600,
                                  recordStates: true,
                                  verbose: 0)
print("Configuration:\n\(configuration)")

let humanPlay = false

if !humanPlay {
    selfPlaysAndRecord(size: configuration.size,
                       numberToWin: configuration.numberToWin,
                       selfPlayTimeInSecs: configuration.selfPlayTimeInSecs,
                       perMoveSimulationTimes: configuration.perMoveSimulationTimes,
                       recordStates: configuration.recordStates,
                       verbose: configuration.verbose)
    exit(0)
} else {
    // Play with human
    playWithHuman(size: configuration.size,
                  numberToWin: configuration.numberToWin,
                  perMoveSimulationTimes: configuration.perMoveSimulationTimes,
                  verbose: configuration.verbose)
}
