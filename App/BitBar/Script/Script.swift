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


// TODO: Use Process.environment
class Script {
  private let path: String
  private let args: [String]
  private var process: Process?
  private var listeners = [Listener]()
  private let listen = Listen(NotificationCenter.default)
  private let finishEvent = Event<Result>()
  private weak var delegate: ScriptDelegate?
  private let event = Event<Void>()
  private var listener: Listener?

  enum Failure {
    case crash(String)
    case exit(String, Int)
    case misuse(String)
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
//     onDidFinish {
// //      self.listen.reset()
//     }
  }

  /**
    Takes an extra block that's invoked when the script finishes
  */
  convenience init(path: String, args: [String] = [], delegate: ScriptDelegate? = nil, autostart: Bool = false, block: @escaping Block<Result>) {
    self.init(path: path, args: args, delegate: delegate, autostart: autostart)
    onDidFinish(block)
  }

  static func isExecutable(path: String, block: @escaping Block<Bool>) {
    var script: Script!
    script = Script(path: "test", args: ["-x", path], autostart: true) { result in
      switch result {
        case .success(_):
          block(true)
        case .failure(_):
          // TODO: Check status code == 1
          block(false)
        script.stop()
      }
    }
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
    var listeners = [Listener]()
    let eofEvent = Event<Void>()
    let terminateEvent = Event<Void>()
    var isEOFEvent = false
    var isTerminateEvent = false
    let isDone = { isEOFEvent && isTerminateEvent }

    process.launchPath = path
    process.arguments = args

    process.standardOutput = pipe
    process.standardError = pipe

    let tryDone = {
      if !isDone() { return }
      let output = buffer.toString().dropLast()
      switch (process.terminationReason, process.terminationStatus) {
      case (.exit, 0):
        self.succeeded(output, status: 0)
      case (.exit, 2):
        self.failed(.misuse(output))
      case let (.exit, code):
        self.failed(.exit(output, Int(code)))

      case let (.uncaughtSignal, code):
        self.failed(.exit(output, Int(code)))
      }

      buffer.close()
      listeners = []
    }

    listeners.append(eofEvent.on {
      isEOFEvent = true
      tryDone()
    })

    listeners.append(terminateEvent.on {
      isTerminateEvent = true
      tryDone()
    })

    process.terminationHandler = { _ in
      terminateEvent.emit()
    }

    listen.on(.NSFileHandleDataAvailable, for: handler) {
      let data = handler.availableData
      buffer.append(data: data)

      if buffer.isFinish() {
        for result in buffer.reset() {
          self.succeeded(result, status: 0)
        }
        handler.waitForDataInBackgroundAndNotify()
        return
      }

      if data.isEOF() {
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
    // FIXME: Check if path is executable
    // Script.isExecutable(path: path) { isExec in
    //   if isExec { self.failed(.crash("file is not executable")) }
    //   else { self.failed(.crash(message)) }
    // }
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
    Async.main {
      self.delegate?.scriptDidReceiveOutput(result, status)
      self.finishEvent.emit(.success(result, Int(status)))
    }
  }

  private func failed(_ message: Failure) {
    Async.main {
      // TODO: Fix this
      self.delegate?.scriptDidReceiveError("X", -1)
      self.finishEvent.emit(.failure(message))
    }
  }
}
