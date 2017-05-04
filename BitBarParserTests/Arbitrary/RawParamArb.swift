@testable import BitBarParser
import SwiftCheck

extension Raw.Param: Arbable {
  typealias Param = Raw.Param

  static let font_t = string.map(Param.font)
  static let size_t = float.suchThat { $0 >= 0 }.map(Param.size)
  static let length_t = natural.map(Param.length)
  static let color_t = Color.arbitrary.map(Param.color)
  static let bash_t = string.map(Param.bash)
  static let dropdown_t = bool.map(Param.dropdown)
  static let emojize_t = bool.map(Param.emojize)
  static let ansi_t = bool.map(Param.ansi)
  static let trim_t = bool.map(Param.trim)
  static let checked_t = bool.map(Param.checked)
  static let alternate_t = bool.map(Param.alternate)
  static let refresh_t = bool.map(Param.refresh)
  /* TODO */
  // static let terminal_t = bool.map(Param.terminal)
  static let href_t = url.map(Param.href)
  static let image_t = Image.arbitrary.map(Param.image)
  static let action_t = [refresh_t, bash_t, href_t].one()

  static let argument_t: Gen<Param> = Gen<(Int, String)>.zip(Int.arbitrary.suchThat { $0 >= 0 }, string).map {
    return .argument($0, $1)
  }

  static let params = [
    font_t, size_t, length_t, color_t, dropdown_t, emojize_t, ansi_t,
    trim_t, checked_t, alternate_t,
    argument_t, image_t, action_t
  ]

  static let params2 = [
    font_t, size_t, length_t, color_t, emojize_t, ansi_t, trim_t
  ]

  public static var arbitrary: Gen<Param> {
    return params.one()
  }

  var output: String {
    switch self {
    case let .font(name):
      return "font=\(name.quoted())"
    case let .size(value):
      return "size=\(value)"
    case let .length(value):
      return "length=\(value)"
    case let .emojize(state):
      return "emojize=\(state)"
    case let .ansi(state):
      return "ansi=\(state)"
    case let .trim(state):
      return "trim=\(state)"
    case let .color(color):
      return color.output
    case let .bash(path):
      return "bash=\(path.quoted())"
    case let .dropdown(state):
      return "dropdown=\(state)"
    case let .href(url):
      return "href=\(url.quoted())"
    case let .image(image):
      return image.output
    case let .terminal(state):
      return "terminal=\(state)"
    case let .refresh(state):
      return "refresh=\(state)"
    case let .alternate(state):
      return "alternate=\(state)"
    case let .checked(state):
      return "checked=\(state)"
    case let .argument(index, value):
      return "param\(index)=\(value.quoted())"
    case let .error(a, b, c):
      preconditionFailure("Not implemented: \(a) \(b) \(c)")
    }
  }

  public static func ==== (lhs: Raw.Param, rhs: Raw.Param) -> Property {
    switch (lhs, rhs) {
    case let (.font(f1), .font(f2)):
      return f1 ==== f2
    case let (.size(s1), .size(s2)):
      return s1 ==== s2
    case let (.length(l1), .length(l2)):
      return l1 ==== l2
    case let (.emojize(e1), .emojize(e2)):
      return e1 ==== e2
    case let (.trim(t1), .trim(t2)):
      return t1 ==== t2
    case let (.ansi(a1), .ansi(a2)):
      return a1 ==== a2
    case let (.color(c1), .color(c2)):
      return c1 ==== c2
    case let (.bash(b1), .bash(b2)):
      return b1 ==== b2
    case let (.dropdown(d1), .dropdown(d2)):
      return d1 ==== d2
    case let (.href(h1), .href(h2)):
      return h1 ==== h2
    case let (.image(i1), .image(i2)):
      return i1 ==== i2
    case let (.terminal(t1), .terminal(t2)):
      return t1 ==== t2
    case let (.refresh(r1), .refresh(r2)):
      return r1 ==== r2
    case let (.alternate(a1), .alternate(a2)):
      return a1 ==== a2
    case let (.checked(c1), .checked(c2)):
      return c1 ==== c2
    case let (.argument(i1, a1), .argument(i2, a2)):
      return i1 ==== i2 ^&&^ a1 ==== a2
    case let (.error(e11, e12, e13), .error(e21, e22, e23)):
      return e11 ==== e21 ^&&^ e12 ==== e22 ^&&^ e13 ==== e23
    default:
      return false <?> "Raw.Param: \(lhs) != \(rhs)"
    }
  }

}
