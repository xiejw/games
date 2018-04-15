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
      filemgr.createFile(atPath:fileName, contents: nil)
      print("File \(fileName) created")
    }
    fs = FileHandle(forWritingAtPath: fileName)!
  }
  
  deinit {
    fs.closeFile()
    print("File \(fileName) closed")
  }
  
  let newline = "\n".data(using: .utf8)!
  
  func save(state: State, nextPlayer: Player, move: Move, win: Bool) {
    queue.sync(flags: .barrier, execute: {
      var result = [String]()
      result.append(String(win ? 1.0 : -1.0))
      result.append(String(nextPlayer == .BLACK ? 1 : 0))
      result.append(String(move.x))
      result.append(String(move.y))
      result.append(state.toString())
      
      self.fs.seekToEndOfFile()
      self.fs.write(result.joined(separator: ",").data(using: .utf8)!)
      self.fs.write(self.newline)
    })
  }
}
