import Foundation

class Logger {
    let fileName: String
    let fs: FileHandle

    init() {
        fileName = "/tmp/game-logger.txt"

        let filemgr = FileManager.default

        if filemgr.fileExists(atPath: fileName) {
            print("File \(fileName) already exists. Append logging to the end.")
        } else {
            filemgr.createFile(atPath: fileName, contents: nil)
            print("File \(fileName) created")
        }
        fs = FileHandle(forWritingAtPath: fileName)!
    }

    deinit {
        print("Close logger \(fileName)")
        fs.closeFile()
    }

    let newline = "\n".data(using: .utf8)!

    func logAndPrint(_ message: String) {
        print(message)
        fs.seekToEndOfFile()
        fs.write(message.data(using: .utf8)!)
        fs.write(newline)
    }
}
