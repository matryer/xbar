import Quick
import Nimble
import EmitterKit

@testable import BitBar
class ExecutablePluginTests: Helper {
  override func spec() {
    let path = toFile("complex.sh")

    it("should load plugin") {
      // let plugin = ExecutablePlugin(path: path, file: File("complex", 5000, "sh"))
      // var i = 0
      // var listen: Listener!
      // listen = plugin.event.on { output in
      //   print(listen, output)
      //   i += 1
      // }
      //
      // expect(i).toEventually(equal(1))
    }
  }
}