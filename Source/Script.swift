import Swift
import EmitterKit
import SwiftTryCatch
import Foundation

// TODO: Implement Process.environment
class Script {
  private let path: String
  private let args: [String]
  private var list: Listener?
  private var list2: Listener?
  private let listen = Listen(NotificationCenter.default)
  private weak var delegate: ScriptDelegate?

  var process = Process()
  var pipe = Pipe()
  var buffer = Buffer()
  var handler: FileHandle
  // var terminateEvent: Event<String>
  var isEOFEvent = false
  var isTerminateEvent = false
  var isStream = false
  // let eofEvent: Event<String>
  var event: GEvent?

  func isDone() -> Bool {
    return isEOFEvent && isTerminateEvent && !isStream
  }


  /**
    @path Full path to script to be executed
    @args Argument to be passed to @path
    @delegate Called when finished executing script
  */
  init(path: String, args: [String] = [], delegate: ScriptDelegate? = nil, autostart: Bool = false) {
    handler = pipe.fileHandleForReading
    self.delegate = delegate
    // terminateEvent = Event<String>()
    // eofEvent = Event<String>()
    self.path = path
    self.args = args

    if autostart { start() }
  }

  /**
    Is the script running?
  */
  func isRunning() -> Bool {
    return process.isRunning
  }

  /**
    Stop all running tasks started by this instance
  */
  func stop() {
    if isRunning() {
      process.terminate()
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

  func processIfDone() {
    // if !isDone() { return }
    let output = buffer.toString()
    switch (process.terminationReason, process.terminationStatus) {
    case (.exit, 0):
      succeeded(output, status: 0)
    case (.exit, 2):
      failed(.misuse(output))
    case let (.exit, code):
      failed(.exit(output, Int(code)))
    case (.uncaughtSignal, 15):
      failed(.terminated)
    case let (.uncaughtSignal, code):
      failed(.exit(output, Int(code)))
    }
    buffer.close()
  }

  func eof() {
    self.isEOFEvent = true
    self.processIfDone()
  }

  func term() {
    self.isTerminateEvent = true
    self.processIfDone()
    self.event?.destroy()
  }

  func start() {
    // stop()
    // handler = pipe.fileHandleForReading
    // eofEvent = Event<Void>()
    // terminateEvent = Event<Void>()
    // isEOFEvent = false
    // isTerminateEvent = false
    // isStream = false
    // isDone = { isEOFEvent && isTerminateEvent && !isStream }

    process.launchPath = path
    process.arguments = args

    process.standardOutput = pipe
    process.standardError = pipe

    setEnv(process)

    process.terminationHandler = { [weak self] _ in
      if let this = self {
       this.term()
      }
    }

    event = listen.on(.NSFileHandleDataAvailable, for: handler) { [weak self] in
      guard let this = self else {
        return print("self not avalible")
      }

      let data = this.handler.availableData

      if !data.isEOF() {
        this.buffer.append(data: data)
      }

      if this.buffer.isFinish() {
        this.isStream = true
        for result in this.buffer.reset() {
          this.succeeded(result, status: 0)
        }
      }

      if data.isEOF() && this.isStream && this.buffer.hasData {
        this.succeeded(this.buffer.toString(), status: 0)
      } else if data.isEOF() {
        this.eof()
      } else {
        this.handler.waitForDataInBackgroundAndNotify()
      }
    }

    handler.waitForDataInBackgroundAndNotify()

    SwiftTryCatch.tryRun({ [weak self] in
      if let this = self {
        this.process.launch()
      }
    }, catchRun: { [weak self] in
      if let this = self {
        if let message = $0?.reason {
          this.handleCrash(message)
        } else {
          this.handleCrash(String(describing: $0))
        }
      }
    }, finallyRun: {
      /* NOP */
    })
  }

  private func handleCrash(_ message: String) {
    failed(.crash(message))
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
