import Foundation

public class Task {
  let task: NSTask
  let inputPipe: NSPipe
  let outputPipe: NSPipe
  let errorPipe: NSPipe

  public var arguments: [AnyObject] {
    get {
      return task.arguments 
    }
    set {
      task.arguments = newValue
    }
  }

  var launched: Bool = false
  var exited: Bool = false

  public var outputString: String
  public var errorString:  String

  public init(_ launchPath: String) {
    task = NSTask()
    task.launchPath = launchPath

    inputPipe  = NSPipe()
    outputPipe = NSPipe()
    errorPipe  = NSPipe()

    // Set the pipes on the task
    task.standardInput  = inputPipe
    task.standardOutput = outputPipe
    task.standardError  = errorPipe

    outputString = ""
    errorString  = ""
  }

  public func launch() {
    task.launch()

    launched = true
  }

  public func launchAndWait() {
    launch()

    task.waitUntilExit()

    func readPipe(pipe: NSPipe) -> String {
      let handle = pipe.fileHandleForReading
      let data = handle.readDataToEndOfFile()
      return NSString(data: data, encoding: NSUTF8StringEncoding)! as String
    }

    outputString = readPipe(outputPipe)
    errorString  = readPipe(errorPipe)

    exited = true
  }

  public func hasAnyOutput() -> Bool {
    let outputTrimmed = outputString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    let errorTrimmed  = errorString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

    return (count(outputTrimmed) > 0 || count(errorTrimmed) > 0)
  }
}
