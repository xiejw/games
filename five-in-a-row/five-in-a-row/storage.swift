// NEED Examine.
import Foundation

class CSVStorage {
    let fileName: String
    let fs: FileHandle
    let queue = DispatchQueue(label: "storage")

    init(fileName: String, deleteFileIfExists: Bool) {
        self.fileName = fileName

        let filemgr = FileManager.default

        if deleteFileIfExists && filemgr.fileExists(atPath: fileName) {
            print("File \(fileName) already exists. Delete it.")
            try! filemgr.removeItem(atPath: fileName)
        }

        if filemgr.fileExists(atPath: fileName) {
            print("File \(fileName) already exists. Append game to the end.")
        } else {
            filemgr.createFile(atPath: fileName, contents: nil)
            print("File \(fileName) created")
        }
        fs = FileHandle(forWritingAtPath: fileName)!
    }

    let newline = "\n".data(using: .utf8)!

    func join() {
        queue.sync(flags: .barrier, execute: {
            self.fs.closeFile()
            print("File \(fileName) closed")
        })
    }

    // Spec: R,NP,DIST,STATE
    // R, Double: Reward {win: 1.0, lose: -1.0 lose, tie: 0.0}
    // NP, INT: Next player { black: 1, white: 0 }
    // DIST, [(INT, INT, DOULE)]: unnormalized distribution (move.x, move.y, distribution), joined by #
    // STATE, [INT]: State of the board, state.toString
    func save(state: State, nextPlayer: Player, legalMoves: [Move], distribution: [Double], reward: Double) {
        queue.async(flags: .barrier, execute: {
            var result = [String]()

            // R
            result.append(String(reward))

            // NP
            result.append(String(nextPlayer == .BLACK ? 1 : 0))

            // DIST
            var stringDist = [String]()
            for (index, move) in legalMoves.enumerated() {
                stringDist.append(String(move.x))
                stringDist.append(String(move.y))
                stringDist.append(String(distribution[index]))
            }
            result.append(stringDist.joined(separator: "#"))

            // DIST
            result.append(state.toString())

            self.fs.seekToEndOfFile()
            self.fs.write(result.joined(separator: ",").data(using: .utf8)!)
            self.fs.write(self.newline)
        })
    }
}
