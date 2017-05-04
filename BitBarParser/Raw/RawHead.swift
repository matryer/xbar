extension Raw {
  struct Head {
    typealias Reduce = (Text, [String], [Tail])
    let title: String
    let params: [Param]
    let menus: [Tail]

    func reduce() -> Menu.Head {
      let text = Text(title: title, params: [])
      let errors = [String]()
      let initial = (text, errors, menus)
      let state = params.reduce(initial) { input, param in
        let (text, errors, menus) = input
        switch param {
        case .bash:
         return invalid(param, reduce: input)
        case let .trim(state) where state:
         return (text.add(param: .trim), errors, menus)
        case .trim:
        return input
        case let .dropdown(state) where !state:
         return (text, errors, [])
        case .dropdown:
        return input
        case .href:
         return invalid(param, reduce: input)
        case .image:
         return invalid(param, reduce: input)
        case let .font(name):
         return (text.add(param: .font(name)), errors, menus)
        case let .size(value):
          return (text.add(param: .size(value)), errors, menus)
        case .terminal:
         return invalid(param, reduce: input)
        case .refresh:
         return invalid(param, reduce: input)
        case let .length(value):
         return (text.add(param: .length(value)), errors, menus)
        case .alternate:
         return invalid(param, reduce: input)
        case let .emojize(state) where state:
         return (text.add(param: .emojize), errors, menus)
        case .emojize:
         return input
        case let .ansi(state) where state:
         return (text.add(param: .ansi), errors, menus)
        case .ansi:
          return input
        case let .color(value):
         return (text.add(param: .color(value)), errors, menus)
        case .checked:
         return invalid(param, reduce: input)
        case .argument:
         return invalid(param, reduce: input)
        case let .error(error, _, _): /* TODO */
          return (text, errors + ["TODO (error): \(error)"], menus)
        }
      }

      return update(state)
    }

    private func invalid(_ param: Raw.Param, reduce: Reduce) -> Reduce {
      switch reduce {
      case let (text, errors, menus):
        return (text, errors + ["Can't add \(param) to Head"], menus)
      }
    }

    private func update(_ state: Reduce) -> Menu.Head {
      switch state {
      case let (_, errors, _) where errors.count > 0:
        return .error(errors)
      case let (text, _, menus):
        return menus.reduce(.text(text, [])) { head, tail in
          return head.add(tail.reduce(), to: tail.level)
        }
      }

    }
  }
}
