import Swift
import Cent
import Foundation
import EmitterKit
import Async

// TODO Handle this error: http://stackoverflow.com/questions/25559608/running-shell-script-with-nstask-causes-posix-spawn-error
class Script {
  private let path: String
  private let args: [String]
  private var events = [Listener]()
  private let finishEvent = Event<Void>()
  private var process: AsyncBlock<(String?, Int32), Void>?
  private weak var delegate: ScriptDelegate?

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
  deinit { stop() }

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
      return self.execute()
    }.main {
      switch $0 {
      case let (.some(output), 0):
        self.delegate?.scriptDidReceiveOutput(output)
      case let (.none, code):
        self.delegate?.scriptDidReceiveError("", code)
      case let (.some(output), code):
        self.delegate?.scriptDidReceiveError(output, code)
      }
      self.finishEvent.emit()
    }
  }

  private func execute() -> (String?, Int32) {
    let task = Process()
    let pipe = Pipe()

    task.launchPath = path
    task.arguments = args

    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    task.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    return (output?.dropLast(), task.terminationStatus)
  }
}
