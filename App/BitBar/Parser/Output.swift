protocol OutputDelegate: class {
  func output(didClickOpenInTerminal: Output)
  func output(didTriggerRefresh: Output)
}

final public class Output: TitleDelegate {
  internal let title: Title
  internal var isStream: Bool
  internal weak var delegate: OutputDelegate?

  init(_ title: Title, _ isStream: Bool) {
    self.title = title
    self.isStream = isStream
    self.title.titlable = self
  }

  internal func name(didClickOpenInTerminal: Title) {
    delegate?.output(didClickOpenInTerminal: self)
  }

  internal func name(didTriggerRefresh: Title) {
    delegate?.output(didTriggerRefresh: self)
  }

  func merge(with output: Output) {
    isStream = output.isStream
    delegate = output.delegate
    title.merge(with: output.title)
  }
}
