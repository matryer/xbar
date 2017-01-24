import Swift
import EmitterKit
import Async
import SwiftTryCatch
import Foundation

// TODO: Use Process.environment
class Script {
  private let path: String
  private let args: [String]
  private var process: Process?
  private var listeners = [Listener]()
  private let listen = Listen(NotificationCenter.default)
  private let finishEvent = Event<Void>()
  private weak var delegate: ScriptDelegate?
  private let event = Event<Void>()
  private var listener: Listener?

  /**
    @path Full path to script to be executed
    @args Argument to be passed to @path
    @delegate Called when finished executing script
  */
  init(path: String, args: [String] = [], delegate: ScriptDelegate? = nil) {
    self.delegate = delegate
    self.path = path
    self.args = args

    onDidFinish {
//      self.listen.reset()
    }
  }

  /**
    Takes an extra block that's invoked when the script finishes
  */
  convenience init(path: String, args: [String] = [], delegate: ScriptDelegate? = nil, block: @escaping Block<Void>) {
    self.init(path: path, args: args, delegate: delegate)
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
      let code = process.terminationStatus
      let output = buffer.toString()
      switch process.terminationReason {
      case .exit:
        self.succeeded(output, status: code)
      case .uncaughtSignal:
        self.failed(output, status: code)
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

      // 0 == EOF
      if data.count == 0 {
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
        self.failed(message, status: -1)
      } else {
        self.failed(String(describing: $0), status: -1)
      }
    }, finallyRun: {
      /* NOP */
    })
  }

  /**
    @once Only listen for one event
    @block Block to be called when process finishes
  */
  func onDidFinish(once: Bool = false, _ block: @escaping Block<Void>) {
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
      self.finishEvent.emit()
    }
  }

  private func failed(_ result: String, status: Int32) {
    Async.main {
      self.delegate?.scriptDidReceiveError(result, status)
      self.finishEvent.emit()
    }
  }
}
