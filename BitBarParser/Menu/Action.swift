extension Menu {
  enum Action {
    case nop
    case refresh
    case script(String, [String], Bool, Bool)
    case href(String, Bool, Bool)
  }
}
