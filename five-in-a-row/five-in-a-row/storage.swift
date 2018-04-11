import Foundation

protocol Storage {
  func save(state: State, blackWinningProbability: Double, whiteWinningProbability: Double)
}

class CSVStorage: Storage {
  
  let fileName: String
  let fs: FileHandle
  
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
  
  func save(state: State, blackWinningProbability: Double, whiteWinningProbability: Double) {
    var result = [String]()
    result.append(String(blackWinningProbability))
    result.append(String(whiteWinningProbability))
    result.append(state.toString())
    
    fs.seekToEndOfFile()
    fs.write(result.joined(separator: ",").data(using: .utf8)!)
    fs.write(newline)
  }
}
