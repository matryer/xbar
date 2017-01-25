import Swift
import EmitterKit
import Async
import SwiftTryCatch
import Foundation

private extension Data {
  func isEOF() -> Bool {
    return count == 0
  }
}

private extension String {
  func inspecting() -> String {
    if isEmpty { return "NOP" }
    return "'" + replace("\n", "\\n").replace("'", "\\'") + "'"
  }
}

extension Script.Result: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .success(message, status):
      return "Succeeded (\(status)): \(message.inspecting())"
    case let .failure(result):
      return String(describing: result)
    }
  }

  func toString() -> String {
    switch self {
    case let .success(message, _):
      return message
    case let .failure(result):
      return String(describing: result)
    }
  }
}

extension Script.Failure: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .crash(message):
      return "Crashed: \(message)"
    case let .exit(message, status):
      return "Failed (\(status)): \(message.inspecting())"
    case let .misuse(message):
      return "Misused (2): \(message.inspecting())"
    case .terminated():
      return "Terminated (15): Manual termination using Script#stop"
    }
  }
}

// TODO: Implement Process.environment
class Script {
  private let path: String
  private let args: [String]
  private var process: Process?
  private var listeners = [Listener]()
  private let listen = Listen(NotificationCenter.default)
  private let finishEvent = Event<Result>()
  private weak var delegate: ScriptDelegate?

  enum Failure {
    case crash(String)
    case exit(String, Int)
    case misuse(String)
    case terminated()
  }

  enum Result {
    case success(String, Int)
    case failure(Failure)
  }

  /**
    @path Full path to script to be executed
    @args Argument to be passed to @path
    @delegate Called when finished executing script
  */
  init(path: String, args: [String] = [], delegate: ScriptDelegate? = nil, autostart: Bool = false) {
    self.delegate = delegate
    self.path = path
    self.args = args

    if autostart { start() }
  }

  /**
    Takes an extra block that's invoked when the script finishes
  */
  convenience init(path: String, args: [String] = [], delegate: ScriptDelegate? = nil, autostart: Bool = false, block: @escaping Block<Result>) {
    self.init(path: path, args: args, delegate: delegate, autostart: autostart)
    onDidFinish(block)
  }

  /**
    Stop all running tasks started by this instance
  */
  func stop() {
    if isRunning() {
      process?.terminate()
    }
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
    let process = Process()
    let pipe = Pipe()
    let buffer = Buffer()
    let handler = pipe.fileHandleForReading
    let eofEvent = Event<Void>()
    let terminateEvent = Event<Void>()
    var isEOFEvent = false
    var isTerminateEvent = false
    var isStream = false
    let isDone = { isEOFEvent && isTerminateEvent && !isStream }

    process.launchPath = path
    process.arguments = args

    process.standardOutput = pipe
    process.standardError = pipe

    let processIfDone = {
      if !isDone() { return }
      let output = buffer.toString().dropLast()
      switch (process.terminationReason, process.terminationStatus) {
      case (.exit, 0):
        self.succeeded(output, status: 0)
      case (.exit, 2):
        self.failed(.misuse(output))
      case let (.exit, code):
        self.failed(.exit(output, Int(code)))
      case (.uncaughtSignal, 15):
        self.failed(.terminated())
      case let (.uncaughtSignal, code):
        self.failed(.exit(output, Int(code)))
      }

      buffer.close()
    }

    eofEvent.once {
      isEOFEvent = true
      processIfDone()
    }

    terminateEvent.once {
      isTerminateEvent = true
      processIfDone()
    }

    process.terminationHandler = { _ in
      terminateEvent.emit()
    }

    listen.on(.NSFileHandleDataAvailable, for: handler) {
      let data = handler.availableData

      if !data.isEOF() {
        buffer.append(data: data)
      }

      if buffer.isFinish() {
        isStream = true
        for result in buffer.reset() {
          self.succeeded(result.dropLast(), status: 0)
        }
      }

      if data.isEOF() && isStream && buffer.hasData {
        self.succeeded(buffer.toString().dropLast(), status: 0)
      } else if data.isEOF() {
        eofEvent.emit()
      } else {
        handler.waitForDataInBackgroundAndNotify()
      }
    }

    handler.waitForDataInBackgroundAndNotify()
    self.process = process

    SwiftTryCatch.tryRun({
      process.launch()
    }, catchRun: {
      if let message = $0?.reason {
        self.handleCrash(message)
      } else {
        self.handleCrash(String(describing: $0))
      }
    }, finallyRun: {
      /* NOP */
    })
  }

  private func handleCrash(_ message: String) {
    self.failed(.crash(message))
  }

  /**
    @once Only listen for one event
    @block Block to be called when process finishes
  */
  func onDidFinish(once: Bool = false, _ block: @escaping Block<Result>) {
    if once {
      finishEvent.once(handler: block)
    } else {
      listeners.append(finishEvent.on(block))
    }
  }

  /**
    Is the script running?
  */
  func isRunning() -> Bool {
    return process?.isRunning ?? false
  }

  private func succeeded(_ result: String, status: Int32) {
    let stdout: Result = .success(result, Int(status))
    Async.main {
      self.delegate?.scriptDidReceive(success: stdout)
      self.finishEvent.emit(stdout)
    }
  }

  private func failed(_ message: Failure) {
    let error: Result = .failure(message)
    Async.main {
      self.delegate?.scriptDidReceive(error: error)
      self.finishEvent.emit(error)
    }
  }
}
