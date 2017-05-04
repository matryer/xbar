//import Quick
//import Nimble
//@testable import BitBar
//
//class ScriptTests: Helper {
// override func spec() {
//   describe("stdout") {
//     it("handles base case") {
//       testSucc("basic.sh", assumed: "Hello\n")
//     }
//
//     it("handles sleep") {
//       testSucc("sleep.sh", assumed: "sleep\n")
//     }
//
//     it("handles args") {
//       testSucc("args.sh", args: ["1", "2", "3"], assumed: "1 2 3\n")
//     }
//
//     it("handles file with space in name") {
//       testSucc("space script.sh", assumed: "Hello\n")
//     }
//   }
//
//   describe("stderr") {
//     it("exit code 1, no output") {
//       testFail("exit1-no-output.sh", assumed: "")
//     }
//
//     it("exit code 1, with output") {
//       testFail("exit1-output.sh", assumed: "Exit 1\n")
//     }
//   }
//
//   describe("env") {
//     it("has BitBarVersion set") {
//       testEnv(path: "version-env.sh", env: "BitBarVersion", value: "3.0.0")
//     }
//   }
//
//   describe("crash") {
//     it("is missing shebang") {
//       testCrash("missing-sh-bin.sh", assumed: "launch path not accessible")
//     }
//
//     it("handles non-executable script") {
//       testCrash("nonexec.sh", assumed: "launch path not accessible")
//     }
//
//     it("handles non-existing file") {
//       testCrash("does-not-exist.sh", assumed: "launch path not accessible")
//     }
//   }
//
//   describe("misuse") {
//     it("handles invalid syntax") {
//       testMisuse("invalid-syntax.sh", assumed: "syntax error: unexpected end of file")
//     }
//   }
//
//   describe("stream") {
//     it("handles one output") {
//       testStream("stream-nomore.sh", assumed: ["A\n~~~\n"])
//     }
//
//     it("handles more then one") {
//       testStream("stream-more.sh", assumed: ["A\n~~~\n", "B\n"])
//     }
//
//     it("handles empty stream") {
//       testStream("stream-nothing.sh", assumed: ["~~~\n"])
//     }
//
//     it("handles sleep") {
//       testStream("stream-sleep.sh", assumed: ["A\n~~~\n", "B\n"])
//     }
//   }
//
//   describe("start/stop") {
//     let path = toFile("sleep.sh")
//     it("doesn't auto start'") {
//       var index = 0
//       _ = Script(path: path) { output in
//         expect(output).to(beASuccess())
//         index += 1
//       }
//
//       expect(index).toEventuallyNot(beGreaterThan(0))
//     }
//
//     it("should autostart") {
//       var index = 0
//       _ = Script(path: path, autostart: true) { output in
//         expect(output).to(beASuccess())
//         index += 1
//       }
//
//       expect(index).toEventually(equal(1), timeout: 10)
//     }
//
//     it("stop running task") {
//       var index = 0
//       let script = Script(path: path) { output in
//         expect(output).to(beTerminated())
//         index += 1
//       }
//
//       script.stop()
//
//       expect(index).toEventuallyNot(beGreaterThan(0))
//     }
//
//     it("should cancel already running scripts") {
//       var index = 0
//       let script = Script(path: path, autostart: false) { output in
//         if index == 4 {
//           expect(output).to(beASuccess())
//         } else {
//           expect(output).to(beTerminated())
//         }
//         index += 1
//       }
//
//       for _ in 0..<5 {
//         script.start()
//       }
//
//       expect(index).toEventually(equal(5), timeout: timeout)
//     }
//
//     it("should be able to restart script") {
//       var index = 0
//       let script = Script(path: path, autostart: true) { output in
//         if index == 1 {
//           expect(output).to(beASuccess())
//         } else {
//           expect(output).to(beTerminated())
//         }
//         index += 1
//       }
//
//       script.restart()
//
//       expect(index).toEventually(equal(2), timeout: timeout)
//       expect(index).toEventuallyNot(beGreaterThan(2))
//     }
//
//     it("should be able to stop a non running script") {
//       var index = 0
//       let script = Script(path: path, autostart: false) { _ in
//         index += 1
//       }
//
//       script.stop()
//       expect(index).toEventuallyNot(beGreaterThan(1))
//     }
//   }
// }
//}
