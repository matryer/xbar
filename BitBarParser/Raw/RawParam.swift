enum Raw {
  enum Param {
    case bash(String) // => Action.script(Script(.bash, .argument))
    case trim(Bool) // Just trim
    case dropdown(Bool) // Remove all menus
    case href(String) // Head: Fail, can't have href, Tail: Action.href(.href)
    case image(Image) // Head: Fail, cant have image, Tail: Tail.image(image)
    case font(String) // Head/Tail.text.add(.font)
    case size(Float) // Head/Tail.text.add(.size)
    case terminal(Bool) // Head: Fail, can't have it, Tail: Add to Action.script, if not, fail
    case refresh(Bool) // Head: fail, Tail: Add to .href or .action
    case length(Int) // Add to Head/Tail.text.add(.length)
    case alternate(Bool) // Head: fail, Tail: Tail.params.add(.alternate)
    case emojize(Bool) // Head/T.text.add(.emojize)
    case ansi(Bool) // H/T.text.add(.ansi)
    case color(Color) // H/T.text.add(color)
    case checked(Bool) // Head: fail, Tail.params.add(.checked)
    case argument(Int, String) // Head: fail, Tail: add to Action.script
    case error(String, String, String) // Head/Tail: replace with warning symbol, add error to submenu
  }
}
