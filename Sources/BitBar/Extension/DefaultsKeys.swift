import SwiftyUserDefaults

extension DefaultsKeys {
  static let pluginPath = DefaultsKey<String?>("pluginPath")
  static let startAtLogin = DefaultsKey<Bool?>("startAtLogin")
  static let disabled = DefaultsKey<Bool?>("userConfigDisabled")
}
