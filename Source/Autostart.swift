import Foundation

/**
 Turn auto login on / off
*/
struct AutoLogin {
  typealias Item = LSSharedFileListItem
  typealias List = LSSharedFileList

  private let resolve = LSSharedFileListItemCopyResolvedURL
  private let create = LSSharedFileListCreate
  private let remove = LSSharedFileListItemRemove
  private let insert = LSSharedFileListInsertItemURL
  private let snapshot = LSSharedFileListCopySnapshot
  private let session = kLSSharedFileListSessionLoginItems!
  private let empty = kLSSharedFileListItemBeforeFirst.takeRetainedValue()
  private let appURL = NSURL.fileURL(withPath: Bundle.main.bundlePath) as NSURL

  private let list: List
  private let items: [Item]

  public enum State {
    case off
    case on
  }

  private enum Result {
    case yes(Item)
    case no(Item)
  }

  /**
    Turn on auto login
  */
  public static func on() {
    set(to: .on)
  }

  /**
    Turn off auto login
  */
  public static func off() {
    set(to: .off)
  }

  /**
    Turn off or on auto login
    I.e AutoLogin.set(to: .on)
  */
  public static func set(to state: State) {
    AutoLogin().set(to: state)
  }

  private init() {
    list = create(nil, session.takeRetainedValue(), nil).takeRetainedValue()
    items = snapshot(list, nil).takeRetainedValue() as! [Item]
  }

  // Change state for current application
  // Wont update the list if already in it
  private func set(to setTo: State) {
    switch (setTo, isEnabled) {
    case let (.on, .no(item)):
      insert(item)
    case let (.off, .yes(item)):
      remove(item)
    case (_, .no(_)):
      break /* Already off */
    case (_, .yes(_)):
      break /* Already on */
    }
  }

  // Does item represent the current application?
  private func isUs(_ item: Item) -> Bool {
    guard let pointer = resolve(item, 0, nil) else {
      return false
    }

    return (pointer.takeRetainedValue() as NSURL).isEqual(appURL)
  }

  // Insert item into startup database
  private func insert(_ item: Item) {
    _ = insert(list, item, nil, nil, appURL as CFURL, nil, nil)
  }

  // Remove item from start up database
  private func remove(_ item: Item) {
    _ = remove(list, item)
  }

  // Is this application currently set to auto login?
  private var isEnabled: Result {
    if items.isEmpty {
      return .no(empty)
    }

    for item in items {
      if isUs(item) {
        return .yes(item)
      }
    }

    return .no(items.last!)
  }
}
