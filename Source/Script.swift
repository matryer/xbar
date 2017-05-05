import Swift
import EmitterKit
import SwiftTryCatch
import Foundation

// TODO: Implement Process.environment
class Script {
  private let path: String
  private let args: [String]
  private var process: Process?
  private let listen = Listen(NotificationCenter.default)
  private weak var delegate: ScriptDelegate?

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
    Is the script running?
  */
  func isRunning() -> Bool {
    return process?.isRunning ?? false
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

    setEnv(process)

    let processIfDone = {
      if !isDone() { return }
      let output = buffer.toString()
      switch (process.terminationReason, process.terminationStatus) {
      case (.exit, 0):
        self.succeeded(output, status: 0)
      case (.exit, 2):
        self.failed(.misuse(output))
      case let (.exit, code):
        self.failed(.exit(output, Int(code)))
      case (.uncaughtSignal, 15):
        self.failed(.terminated)
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

    let event = listen.on(.NSFileHandleDataAvailable, for: handler) {
      let data = handler.availableData

      if !data.isEOF() {
        buffer.append(data: data)
      }

      if buffer.isFinish() {
        isStream = true
        for result in buffer.reset() {
          self.succeeded(result, status: 0)
        }
      }

      if data.isEOF() && isStream && buffer.hasData {
        self.succeeded(buffer.toString(), status: 0)
      } else if data.isEOF() {
        eofEvent.emit()
      } else {
        handler.waitForDataInBackgroundAndNotify()
      }
    }

    eofEvent.once {
      event.destroy()
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

  private func setEnv(_ process: Process) {
    guard let key = kCFBundleVersionKey else { return }
    guard let version = Bundle.main.object(forInfoDictionaryKey: key as String) else { return }
    guard let versionStr = version as? String else { return }
    if process.environment == nil {
      process.environment = [:]
    }

    process.environment!["BitBarVersion"] = versionStr
  }

  private func succeeded(_ result: String, status: Int32) {
    delegate?.scriptDidReceive(
      success: Success(
        status: Int(status),
        output: result
      )
    )
  }

  private func failed(_ message: Failure) {
    delegate?.scriptDidReceive(failure: message)
  }
}
