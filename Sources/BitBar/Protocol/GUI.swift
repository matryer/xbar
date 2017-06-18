import Foundation

protocol GUI {
  var queue: DispatchQueue { get }
  func perform(block: @escaping () -> Void)
}
