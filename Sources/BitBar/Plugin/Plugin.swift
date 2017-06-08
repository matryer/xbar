import Parser
import Async
import Files

/**
  Base plugin responsible for delegating data to
  - the status bar
  - app delegate
  - plugin manager
*/

protocol Plugin: class, Parent, CustomStringConvertible {
  var name: String { get }
  var file: Files.File { get }
  var meta: [String: String] { get }
  var type: String { get }
  weak var manager: Managable? { get }
  func refresh()
  func terminate()
  func start()
  func stop()
  func invoke(_: [String])
}

extension Plugin {
  internal var path: String { return file.path }
  internal var name: String { return file.name }
}
