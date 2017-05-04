extension Raw {
  struct Tail {
    let level: Int
    let title: String
    let params: [Param]

    func reduce() -> Menu.Tail {
      return params.reduce(Acc(title: title)) { acc, param in
        switch param {
        case let .bash(path):
          return acc.add(bash: path)
        case let .trim(state) where state:
          return acc.add(param: .trim)
        case .trim:
          return acc
        case let .dropdown(state): /* TODO */
          return acc.set(dropdown: state)
        case let .href(url):
          return acc.set(href: url)
        case let .image(image):
          return acc.set(image: image)
        case let .font(name):
          return acc.add(param: .font(name))
        case let .size(value):
          return acc.add(param: .size(value))
        case let .terminal(state):
          return acc.set(terminal: state)
        case let .refresh(state):
          return acc.set(refresh: state)
        case let .length(value):
          return acc.add(param: .length(value))
        case .alternate:
          return acc.add(param: .alternate)
        case let .emojize(state) where state:
          return acc.add(param: .emojize)
        case .emojize:
         return acc
        case let .ansi(state) where state:
          return acc.add(param: .ansi)
        case .ansi:
          return acc
        case let .color(value):
          return acc.add(param: .color(value))
        case .checked:
          return acc.add(param: .checked)
        case let .argument(index, value):
          return acc.add(index, value: value)
       case let .error(message, _, _): /* TODO */
          return acc.add(error: message)
        }
      }.reduce()
    }
  }
}
