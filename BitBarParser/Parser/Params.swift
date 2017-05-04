import Foundation
import FootlessParser

extension Pro {
  private static let manager = NSFontManager.shared()
  typealias Param = Raw.Param
  /**
   XColor attribute with hex or color value, i.e color=red or color=#ff00AA
   */
  static var color: P<Param> {
    return Param.color <^> ((ws *> string("color=")) *> (hexColor <|> regularColor))
  }

  /**
   Boolean ansi attribute, i.e ansi=false
   */
  static var ansi: P<Param> {
    return Param.ansi <^> attribute("ansi") { bool }
  }

  /**
   Boolean emojize attribute, i.e emojize=false
   */
  static var emojize: P<Param> {
    return Param.emojize <^> attribute("emojize") { bool }
  }

  /**
   Quote / unquoted image/templateImage attribute, i.e image="c2Rm=="
   */
  static var image: P<Param> {
    return toImage(forKey: "image", isTemplate: false) <|> toImage(forKey: "templateImage", isTemplate: true)
  }

  /**
   Quote / unquoted href attribute, i.e href="http://google.com"
   */
  static var href: P<Param> {
    return Param.href <^> attribute("href") { quoteOrWord }
  }

  /**
   Quote / unquoted font attribute, i.e font="Monaco"
   */
  static var font: P<Param> {
    return { font in
      return .font(font)
      // let has = manager.availableFontFamilies.some {
      //   return $0.lowercased() == font.lowercased()
      // }
      //
      // if has { return .font(font.lowercased()) }

      // return error(message: "not in the list of avalible fonts", key: "font", value: font)
      } <^> attribute("font") { quoteOrWord }
  }

  /**
   Unquoted size attribute as a positive int, i.e size=10
   */
  static var size: P<Param> {
    return Param.size <^> attribute("size") { float }
  }

  /**
   Quote / unquoted bash attribute, i.e bash="/usr/local/bin space"
   */
  static var bash: P<Param> {
    return Param.bash <^> attribute("bash") { quoteOrWord }
  }

  /**
   Boolean alternate attribute, i.e alternate=false
   */
  static var alternate: P<Param> {
    return Param.alternate <^> attribute("alternate") { bool }
  }

  /**
   Boolean checked attribute, i.e checked=true
   */
  static var checked: P<Param> {
    return Param.checked <^> attribute("checked") { bool }
  }

  /**
   Boolean trim attribute, i.e trim=false
   */
  static var trim: P<Param> {
    return Param.trim <^> attribute("trim") { bool }
  }

  /**
   Boolean dropdown attribute, i.e dropdown=false
   */
  static var dropdown: P<Param> {
    return Param.dropdown <^> attribute("dropdown") { bool }
  }

  /**
   Boolean refresh attribute, i.e refresh=false
   */
  static var refresh: P<Param> {
    return Param.refresh <^> attribute("refresh") { bool }
  }

  /**
   Boolean terminal attribute, i.e terminal=false
   */
  static var terminal: P<Param> {
    return Param.terminal <^> attribute("terminal") { bool }
  }

  /**
   Named param with a quoted / unquoted value, i.e param12="A value"
   */
  static var arg: P<Param> {
    let key: P<Int> = string("param") *> digits
    return ws *> (curry(Param.argument) <^> (key <* string("=")) <*> quoteOrWord) <* ws
  }

  /**
   Int length attribute, i.e length=11
   */
  static var length: P<Param> {
    return Param.length <^> attribute("length") { digits }
  }
}
