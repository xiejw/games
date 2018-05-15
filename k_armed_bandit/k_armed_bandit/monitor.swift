import Foundation

// Not thread safe.
class Monitor {
    var valueStore = Dictionary<String, Double>()
    var shouldSummary = Set<String>()
    
    func report(key keyName: String, value: Double, skipSummary: Bool = true) {
        if let baseValue = valueStore[keyName] {
            valueStore[keyName] = baseValue + value
        } else {
            valueStore[keyName] = value
        }
        
        if !skipSummary {
            shouldSummary.insert(keyName)
        }
    }
    
    func summary() {
        for (key, value) in (valueStore.sorted{ $0.0 < $1.0 }) {
            if shouldSummary.contains(key) {
                print("\(key): \(value)")
            }
        }
    }
    
    func save(fName: String) {
        let filemgr = FileManager.default
        if filemgr.fileExists(atPath: fName) {
            print("File \(fName) already exists. Delete it.")
            try! filemgr.removeItem(atPath: fName)
        }
        
        filemgr.createFile(atPath:fName, contents: nil)
        print("File \(fName) created")
        
        let fs = FileHandle(forWritingAtPath: fName)!
        for (key, value) in (valueStore.sorted{ $0.0 < $1.0 }) {
            fs.write("\(key): \(value)\n".data(using: .utf8)!)
        }
        fs.closeFile()
    }
}
