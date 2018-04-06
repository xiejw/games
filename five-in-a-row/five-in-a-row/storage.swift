import Foundation

protocol Storage {
  func save(state: State, winner: Player?)
}

class CSVStorage: Storage {
  
  let focusedPlayer: Player
  let fs: FileHandle
  
  init(fileName: String, focusedPlayer: Player) {
    self.focusedPlayer = focusedPlayer
    
    let filemgr = FileManager.default
    
    if filemgr.fileExists(atPath: fileName) {
      print("File exists")
    } else {
      print("File not found")
      filemgr.createFile(atPath:fileName, contents: nil)
      print("File created")
    }
    fs = FileHandle(forWritingAtPath: fileName)!
  }
  
  deinit {
    fs.closeFile()
    print("File closed")
  }
  
  let newline = "\n".data(using: .utf8)!
  
  func save(state: State, winner: Player?) {
    var result = [String]()
    if winner == focusedPlayer {
      result.append("1")
    } else {
      result.append("0")
    }
    result.append(state.toString())
    fs.seekToEndOfFile()
    fs.write(result.joined(separator: ",").data(using: .utf8)!)
    fs.write(newline)
  }
}
