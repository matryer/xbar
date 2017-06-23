  import Files
import Foundation
import SwiftyBeaver

class MoveExecuteable {
  private let log = SwiftyBeaver.self
  private let cliPath = "/usr/local/bin/bitbar"
  private let destCliURL: URL
  private let fileManager = FileManager.default

  init() {
    destCliURL = URL(fileURLWithPath: cliPath, isDirectory: false)
  }

  func execute() {
    guard let cliURL = Bundle.main.url(forAuxiliaryExecutable: "CLI") else {
      return log.error("Could not find embedded executable")
    }

    tryRemovingExistingBinary()
    tryCopyingBinaryToDestPath(source: cliURL)
    log.info("Copied executable \(cliURL.absoluteString) to \(cliPath)")
  }

  private var destExists: Bool {
    return fileManager.fileExists(atPath: cliPath)
  }

  private var destCliFile: Files.File? {
    guard destExists else { return nil }
    do {
      return try Files.File(path: cliPath)
    } catch {
      log.verbose("Dest file \(cliPath) does not exist: \(error)")
    }

    return nil
  }

  private func tryRemovingExistingBinary() {
    guard let dest = destCliFile else { return }

    do {
      try dest.delete()
    } catch {
      log.error("Could not delete file \(dest.path) due to: \(error)")
    }
  }

  private func tryCopyingBinaryToDestPath(source: URL) {
    do {
      try fileManager.copyItem(at: source, to: destCliURL)
    } catch {
      log.error("Could not copy \(source.absoluteString) to \(destCliURL.absoluteString): \(error)")
    }
  }
}
