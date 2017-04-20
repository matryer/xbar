import Swift
import Cocoa
import SwiftyTimer

class ExecutablePlugin: Plugin, ScriptDelegate {
  private var script: Script!
  private var timer: Timer!

  override init(path: String, file: File) {
    super.init(path: path, file: file)
    script = Script(path: path, delegate: self)
    timer = Timer.every(interval.seconds, scheduleDidTick)
    script.start()
  }

  /**
    Run @path once every @interval seconds
  */
  override func show() {
    script.start()
    timer.start()
  }

  /**
    Stop timer and script
  */
  override func hide() {
    timer.invalidate()
    script.stop()
  }

  /**
    Restart the script
  */
  override func refresh() {
    script.restart()
  }

  /**
    In this case, terminate() and hide() do the same thing
  */
  override func terminate() {
    hide()
  }

  /**
    Succeeded running @path
    Sending data to parent plugin class
  */
  func scriptDidReceive(success result: Script.Result) {
    didReceivedOutput(result.toString())
  }

  /**
    Failed running @path
    Sending error to parent plugin class
  */
  func scriptDidReceive(error message: Script.Result) {
    didReceiveError(String(describing: message))
  }

  /**
    Called once every @interval seconds by @timer
    Terminates any ongoing script
  */
  private func scheduleDidTick() {
    script.start()
  }
}
