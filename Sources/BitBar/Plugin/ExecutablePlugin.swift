import SwiftyTimer
import SwiftyBeaver
import DateToolsSwift
import Script
import Files

class ExecutablePlugin: Plugin, Scriptable {
  internal let log = SwiftyBeaver.self
  private let scriptName: String
  private var script: Script
  internal let file: Files.File
  private var timer: Timer?
  private var interval: Double
  internal weak var manager: Managable?
  internal weak var root: Parent?

  public var description: String {
    return "Exectable(name: \(scriptName), file: \(file.name), interval: \(interval))"
  }

  init(name: String, interval: Double, file: Files.File, manager: Managable) {
    self.scriptName = name
    self.interval = interval
    self.manager = manager
    self.file = file
    self.script = Script(path: file.path)
    self.root = manager
    newTimer()
    self.script.delegate = self
    self.script.start()
  }

  /**
    Run @path once every @interval seconds
  */
  func start() {
    script.start()
    timer?.start()
  }

  /**
    Stop timer and script
  */
  func stop() {
    timer?.invalidate()
    script.stop()
  }

  /**
    Restart the script
  */
  func refresh() {
    newTimer()
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
    manager?.plugin(didReceiveOutput: result.output)
  }

  /**
    Failed running @path
    Sending error to parent plugin class
  */
  func scriptDidReceive(failure error: Script.Failure) {
    switch error {
    case .terminated:
      print("[Log] Plugin \(name) was terminated")
    default:
      manager?.plugin(didReceiveError: String(describing: error))
    }
  }

  func invoke(_ args: [String]) {
    script = Script(path: path, args: args, delegate: self, autostart: true)
    newTimer()
  }

  /**
    Called once every @interval seconds by @timer
    Terminates any ongoing script
  */
  private func scheduleDidTick() {
    script.start()
  }

  private func newTimer() {
    self.timer?.invalidate()
    self.timer = Timer.every(interval.seconds, scheduleDidTick)
  }

  var type: String { return "Interval" }
  var meta: [String: String] {
    let date = Date()
    return [
      "Run": "Every " + date.shortTimeAgo(since: date - Int(interval))
    ]
  }
}
