import Swift
import Cent
// TODO Handle this error: http://stackoverflow.com/questions/25559608/running-shell-script-with-nstask-causes-posix-spawn-error
import Foundation
import EmitterKit
import Async

// TODO: Use everywhere
typealias Block<T> = () -> T

class Script: Base {
  let path: String
  let args: [String]
  var events = [Listener]()
  let finishEvent = Event<Void>()
  var process: Async?
  weak var delegate: ScriptDelegate?

  init(path: String, args: [String] = [], delegate: ScriptDelegate? = nil) {
    self.delegate = delegate
    self.path = path
    self.args = args
  }

  convenience init(path: String, args: [String] = [], delegate: ScriptDelegate? = nil, block: @escaping Block<Void>) {
    self.init(path: path, args: args, delegate: delegate)
    events.append(finishEvent.on(block))
  }

  init(path: String, args: [String] = []) {
    self.path = path
    self.args = args
    super.init()
  }

  func stop() {
    process?.cancel()
  }

  func restart() {
    stop()
    start()
  }

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
