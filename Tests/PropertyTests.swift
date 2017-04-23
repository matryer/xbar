import SwiftCheck
import XCTest
@testable import BitBar

class PropertyTests: XCTestCase {
  func testMenu() {
    verify(name: "menu", parser: Pro.menu, gen: Menu.arbitrary)
  }

  func testTitle() {
    verify(name: "title", parser: Pro.output, gen: Title.arbitrary)
  }

  func testSubMenu() {
    verify(name: "submenu", parser: Pro.submenu, gen: Menu.submenu)
  }

  func testTerminal() {
    verify(name: "terminal", parser: Pro.getTerminal(), gen: Terminal.arbitrary)
  }

  func testImage() {
    // TODO
  //  verify(name: "image", parser: Pro.getImage(), gen: Image.arbitrary)
  }

  func testTrim() {
    verify(name: "trim", parser: Pro.getTrim(), gen: Trim.arbitrary)
  }

  func testRefresh() {
    verify(name: "refresh", parser: Pro.getRefresh(), gen: Refresh.arbitrary)
  }

  func testArgument() {
    verify(name: "argument", parser: Pro.arg, gen: Argument.arbitrary)
  }

  func testEmojize() {
    verify(name: "emojize", parser: Pro.getEmojize(), gen: Emojize.arbitrary)
  }

  func testDropdown() {
    verify(name: "dropdown", parser: Pro.getDropdown(), gen: Dropdown.arbitrary)
  }

  func testAnsi() {
    verify(name: "ansi", parser: Pro.getAnsi(), gen: Ansi.arbitrary)
  }

  func testAlternate() {
    verify(name: "alternate", parser: Pro.getAlternate(), gen: Alternate.arbitrary)
  }

  func testColor() {
    verify(name: "color", parser: Pro.getColor(), gen: BitBar.Color.arbitrary)
  }

  // TODO: 'templateImage' is currenty not being tested, only 'image'
  // func testTemplateImage() {
  // verify(name: "templateImage", parser: Pro.getTemplateImage(), gen: Image.arbitrary)
  // }

  func testSize() {
    verify(name: "size", parser: Pro.getSize(), gen: Size.arbitrary)
  }

  func testBash() {
    verify(name: "bash", parser: Pro.getBash(), gen: Bash.arbitrary)
  }

  func testFont() {
    verify(name: "font", parser: Pro.getFont(), gen: Font.arbitrary)
  }

  func testHref() {
    verify(name: "href", parser: Pro.getHref(), gen: Href.arbitrary)
  }

  func testLength() {
    verify(name: "length", parser: Pro.getLength(), gen: Length.arbitrary)
  }
}
