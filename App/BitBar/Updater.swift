import Sparkle

class Updater: NSObject, SUUpdaterDelegate {
  let updater = SUUpdater.shared()
  var isEnabled = true

  override init() {
    super.init()
    updater?.delegate = self
    updater?.automaticallyChecksForUpdates = true
    updater?.feedURL = App.updatePath
    updater?.sendsSystemProfile = true
    check()
  }

  func check() {
    guard isEnabled else { return }
    guard !App.isInTestMode() else { return }
    updater?.checkForUpdatesInBackground()
  }

  func disable() {
    isEnabled = false
  }

  func enable() {
    isEnabled = true
  }

  public func userDidCancelDownload(_ updater: SUUpdater!) {
    print("[LOG] User did cancel download")
  }
}
