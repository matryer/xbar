import Files

protocol Managable: class, Parent {
  func plugin(didReceiveOutput: String)
  func plugin(didReceiveError: String)
}

class StreamablePlugin: Plugin, ScriptDelegate {
  private let scriptName: String
  private let script: Script
  internal let file: Files.File
  internal weak var manager: Managable?
  internal weak var root: Parent?

  public var description: String {
    return "Streamable(name: \(scriptName), file: \(file.name))"
  }

  init(name: String, file: Files.File, manager: Managable) {
    self.scriptName = name
    self.manager = manager
    self.file = file
    self.script = Script(path: file.path)
    self.root = manager
    self.script.delegate = self
    self.script.start()
  }

  /**
    Run @path once every @interval seconds
  */
  func start() {
    script.start()
  }

  /**
    Stop timer and script
  */
  func stop() {
    script.stop()
  }

  /**
    Restart the script
  */
  func refresh() {
    script.restart()
  }

  /**
    In this case, terminate() and hide() do the same thing
  */
  func terminate() {
    script.stop()
  }

  /**
    Succeeded running @path
    Sending data to parent plugin class
  */
  func scriptDidReceive(success result: Script.Success) {
    if !script.isRunning() {
      manager?.plugin(didReceiveError: "Streaming script is no longer running")
    } else {
      manager?.plugin(didReceiveOutput: result.output)
    }
  }

  /**
    Failed running @path
    Sending error to parent plugin class
  */
  func scriptDidReceive(failure error: Script.Failure) {
    switch error {
    case .terminated:
      manager?.plugin(didReceiveError: "Streaming script is no longer running")
    default:
      manager?.plugin(didReceiveError: String(describing: error))
    }
  }

  var type: String { return "Streamable" }
  var meta: [String: String] {
    return [:]
  }
}
