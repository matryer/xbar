import Cocoa

final class Size: IntValue {
  override func applyTo(menu: MenuDelegate) {
    // let size = CGFloat(getValue())
    //
    // guard let name = menu.font?.fontName    else {
    //   return print("No default font name found")
    // }
    //
    // guard let font = NSFont(name: name, size: size) else {
    //   return print("No default font found with size \(size) and name \(getValue())")
    // }

    menu.update(size: getValue())
  }
}
