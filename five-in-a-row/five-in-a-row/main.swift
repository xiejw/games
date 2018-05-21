import Foundation

struct Configuration {
    var size: Int
    var numberToWin: Int
    var selfPlayTimeInSecs: Double
    var perMoveSimulationTimes: Int
    var recordStates: Bool
    var vsHuman: Bool
    var verbose: Int = 0
}

let configuration: Configuration

if let value = ProcessInfo.processInfo.environment["RL_TIMES_IN_SECS"] {
    // Part of RL loop.
    configuration = Configuration(size: 8,
                                  numberToWin: 5,
                                  selfPlayTimeInSecs: Double(value)!,
                                  perMoveSimulationTimes: 1600,
                                  recordStates: true,
                                  vsHuman: false,
                                  verbose: 0)
} else {
    configuration = Configuration(size: 8,
                                  numberToWin: 5,
                                  selfPlayTimeInSecs: 4.0,
                                  perMoveSimulationTimes: 1600,
                                  recordStates: true,
                                  vsHuman: false,
                                  verbose: 1)
}
print("Configuration:\n\(configuration)")


if !configuration.vsHuman {
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
