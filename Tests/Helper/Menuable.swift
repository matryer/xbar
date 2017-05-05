import AppKit
@testable import BitBar

protocol Menuable {
  var isEnabled: Bool { get }
  var banner: Mutable { get }
  var menus: [Menuable] { get }
  var image: NSImage? { get }
  var isSeparator: Bool { get }
  var isChecked: Bool { get }
  var isAlternate: Bool { get }
  var items: [NSMenuItem] { get }

  func get(at: [Int], rem: [Int]) throws -> Menuable
}

extension Menuable {
  var menus: [Menuable] {
    return items.reduce([]) { acc, item in
      switch item {
      case is Menuable:
        return acc + [item as! Menuable]
      case _ where item.isSeparatorItem:
        return acc + [Menu(isSeparator: true)]
      default:
        return acc
      }
    }
  }

  func get(at indexes: [Int], rem: [Int] = []) throws -> Menuable {
    guard let index = indexes.first() else {
      return self
    }
    if menus.isEmpty { throw NoMatch.stop(rem) }
    return try menus[index].get(at: indexes.rest(), rem: rem + [index])
  }
}
