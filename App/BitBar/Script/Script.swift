import Swift
import Cent
import Foundation
import EmitterKit
import Async

// TODO Handle this error: http://stackoverflow.com/questions/25559608/running-shell-script-with-nstask-causes-posix-spawn-error

class Script: Base {
  let path: String
  let args: [String]
  var events = [Listener]()
  let finishEvent = Event<Void>()
  var process: Async?
  var delegate: ScriptDelegate?

  /**
    @path Full path to script to be executed
    @args Argument to be passed to @path
    @delegate Called when finished executing script
  */
  init(path: String, args: [String] = [], delegate: ScriptDelegate? = nil) {
    self.delegate = delegate
    self.path = path
    self.args = args
  }

  /**
    Takes an extra block that's invoked when the script finishes
  */
  convenience init(path: String, args: [String] = [], delegate: ScriptDelegate? = nil, block: @escaping Block<Void>) {
    self.init(path: path, args: args, delegate: delegate)
    events.append(finishEvent.on(block))
  }

  /**
    Stop all running tasks started by this instance
  */
  func stop() {
    process?.cancel()
  }

  /**
    Restart script. Does not wait until running script finishes
  */
  func restart() {
    stop()
    start()
  }

  /**
    Start script

    1. Stops all current running scripts started by the instance
    2. Execute @path with @args in a background thread
    3. When done, notify listeners that the script terminated
  */
  func start() {
    stop()
    process = Async.background {
      switch self.shell(self.path, self.args) {
      case let (.some(output), 0):
        self.delegate?.scriptDidReceiveOutput(output)
      case let (.none, code):
        self.delegate?.scriptDidReceiveError("", code)
      case let (.some(output), code):
        self.delegate?.scriptDidReceiveError(output, code)
      }
    }.main {
      self.finishEvent.emit()
    }
  }

  private func shell(_ launchPath: String, _ arguments: [String] = []) -> (String?, Int32) {
    let task = Process()
    let pipe = Pipe()

    task.launchPath = launchPath
    task.arguments = arguments

    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    task.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    return (output?.dropLast(), task.terminationStatus)
  }

  deinit { stop() }
}
