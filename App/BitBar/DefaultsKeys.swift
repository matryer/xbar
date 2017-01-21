import SwiftyUserDefaults

extension DefaultsKeys {
  /* An absolute path to the users plugin folder */
  static let pluginPath = DefaultsKey<String?>("pluginPath")

  /* Should the application start on login? */
  static let startAtLogin = DefaultsKey<Bool?>("startAtLogin")
}
