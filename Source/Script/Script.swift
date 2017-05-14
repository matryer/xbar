import Swift
import SwiftTryCatch
import Foundation

// TODO: Implement Process.environment
class Script {
  private let path: String
  private let args: [String]
  private var process: Process?
  private let center = NotificationCenter.default
  private var buffer: Buffer?
  private var isEOFEvent = false
  private var isTerminateEvent = false
  private var isStream = false
  private var handler: FileHandle?
  internal weak var delegate: ScriptDelegate?

  /**
    @path Full path to script to be executed
    @args Argument to be passed to @path
    @delegate Called when finished executing script
  */
  init(path: String, args: [String] = [], delegate: ScriptDelegate, autostart: Bool = false) {
    self.delegate = delegate
    self.path = path
    self.args = args

    if autostart { start() }
  }

  /**
    @path Full path to script to be executed
    @args Argument to be passed to @path
    @delegate Called when finished executing script
  */
  init(path: String, args: [String] = []) {
    self.path = path
    self.args = args
  }

  /**
    Is the script running?
  */
  func isRunning() -> Bool {
    return process?.isRunning ?? false
  }

  private func terminate() {
    SwiftTryCatch.tryRun({ [weak process] in
      process?.terminate()
    }, catchRun: { error in
      print("[Error] Could not terminate due to \(String(describing: error)) script")
    }, finallyRun: {
      /* NOP */
    })
  }

  func stop() {
    if isRunning() { terminate() }
    center.removeObserver(self)
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
    let pipe = Pipe()
    process = Process()
    buffer = Buffer()
    handler = pipe.fileHandleForReading

    isEOFEvent = false
    isTerminateEvent = false
    isStream = false

    process?.launchPath = path

    process?.arguments = args

    process?.standardOutput = pipe
    process?.standardError = pipe

    setDefaultEnv()
    process?.terminationHandler = { [weak self] _ in
      self?.terminateEvent()
    }

    center.addObserver(
      self,
      selector: #selector(didCallNotification),
      name: .NSFileHandleDataAvailable,
      object: handler
    )

    handler!.waitForDataInBackgroundAndNotify()

    SwiftTryCatch.tryRun({ [weak self] in
      self?.process?.launch()
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

  private func setDefaultEnv() {
    setEnv(key: "BitBar", value: "true")

    if isDarkMode {
      setEnv(key: "BitBarDarkMode", value: "true")
    }

    if let version = self.version {
      setEnv(key: "BitBarVersion", value: version)
    }
  }

  private var version: String? {
    guard let key = kCFBundleVersionKey else {
      return nil
    }

    guard let version = Bundle.main.object(forInfoDictionaryKey: key as String) else {
      return nil
    }

    return version as? String
  }

  private var isDarkMode: Bool {
    return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
  }

  private func setEnv(key: String, value: String) {
    guard let process = self.process else {
      return print("[Error] Can't set \(key) with \(value), no process")
    }

    if process.environment == nil {
      process.environment = [:]
    }

    process.environment![key] = value
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

  @objc private func didCallNotification() {
    guard let socket = handler else {
      return print("[Log] No handler to call in didCallNotification()")
    }

    let data = socket.availableData

    if !data.isEOF() {
      buffer!.append(data: data)
    }

    if buffer!.isFinish() {
      isStream = true
      for result in buffer!.reset() {
        succeeded(result, status: 0)
      }
    }

    if data.isEOF() && isStream && buffer!.hasData {
      succeeded(buffer!.toString(), status: 0)
    } else if data.isEOF() {
      eofEvent()
    } else {
      socket.waitForDataInBackgroundAndNotify()
    }
  }

  private func processIfDone() {
    if !isDone() { return }
    let output = self.buffer!.toString()
    switch (process!.terminationReason, process!.terminationStatus) {
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

    buffer!.close()
  }

  private func isDone() -> Bool {
    return isEOFEvent && isTerminateEvent && !isStream
  }

  private func eofEvent() {
    isEOFEvent = true
    processIfDone()
    center.removeObserver(self)
  }

  private func terminateEvent() {
    isTerminateEvent = true
    processIfDone()
  }
}
