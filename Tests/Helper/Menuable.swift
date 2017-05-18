import AppKit
import Parser
@testable import BitBar

var eventRefs = [UInt: [MenuEvent]]()
var menuRefs = [MockParent: Menuable]()

protocol Menuable: class {
  var isClickable: Bool { get }
  var keyEquivalent: String { get }
  var isEnabled: Bool { get }
  var banner: Mutable { get }
  var menus: [Menuable] { get }
  var image: NSImage? { get }
  var isSeparator: Bool { get }
  var isChecked: Bool { get }
  var isAlternate: Bool { get }
  var items: [NSMenuItem] { get }
  var act: Action { get }
  func onWillBecomeVisible()
  weak var root: Parent? { get set }
  func get(at: [Int], rem: [Int]) throws -> Menuable
  func onDidClick()
}

extension Menuable {
  var act: Action { return .nop }
  var menus: [Menuable] {
    return items.reduce([]) { acc, item in
      switch item {
      case is Menuable:
        return acc + [item as! Menuable]
      case _ where item.isSeparatorItem:
        return acc + [Menu(title: "-")]
      default:
        return acc
      }
    }
  }

  var args: [String] {
    switch act {
    case let .script(script):
      return script.args
    default:
      return []
    }
  }

  func get(at indexes: [Int], rem: [Int] = []) throws -> Menuable {
    guard let index = indexes.first() else {
      return self
    }
    if menus.isEmpty { throw NoMatch.stop(rem) }
    if index >= menus.count {
      preconditionFailure("Index: \(index) not found in \(menus.count)")
    }
    return try menus[index].get(at: indexes.rest(), rem: rem + [index])
  }

  var id: UInt {
    return UInt(bitPattern: ObjectIdentifier(self))
  }

  var events: [MenuEvent] {
    return eventRefs[id] ?? []
  }

  func set(parent: MockParent) {
    menuRefs[parent] = self
    eventRefs[id] = []
    root = parent
  }
}
