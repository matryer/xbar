import Quick
import Nimble
@testable import BitBar

class DropdownTests: Helper {
  override func spec() {
    let up = { (_ input: String..., block: @escaping (Title) -> Void) in
      self.match(Pro.title, input.joined() + "\n") { (menu) in
        block(menu)
      }
    }

    it("should deactivate the menu as well as remove as its children") {
      up("A\n---\nB|dropdown=false\n--C\n----D\n------E\n--------F|refresh=true\n") { title in
        expect(the(title, at: [0])).notTo(beClickable())
        expect(the(title, at: [0])).to(have(subMenuCount: 0))
      }
    }
  }
}
