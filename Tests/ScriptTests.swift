import Quick
import Nimble
@testable import BitBar

class ScriptTests: Helper {
  override func spec() {
    beforeEach {
      Nimble.AsyncDefaults.Timeout = 5
    }

    describe("stdout") {
      it("handles base case") {
        expect("basic.sh").toEventually(succeed(with: "Hello\n"))
      }

      it("handles sleep") {
        expect("sleep.sh").toEventually(succeed(with: "sleep\n"))
      }

      it("handles args") {
        expect("args.sh".withArgs(["1", "2", "3"])).toEventually(succeed(with: "1 2 3\n"))
      }

      it("handles file with space in name") {
        expect("space script.sh").toEventually(succeed(with: "Hello\n"))
      }

      describe("env") {
        it("should have BitBarVersion set") {
          expect("version-env.sh").toEventually(succeed(with: "3.0.0\n"))
        }

        it("should not set BitBarDarkMode") {
          expect("bitbar-dark-env.sh").toEventually(succeed(with: "\n"))
        }

        it("should have BitBar set") {
          expect("bitbar-env.sh").toEventually(succeed(with: "true\n"))
        }
      }

      describe("stream") {
        it("handles one output") {
          expect("stream-nomore.sh").toEventually(succeed(with: "A\n"))
        }

        it("handles more then one") {
          expect("stream-more.sh").toEventually(succeed(with: ["A\n", "B\n"]))
        }

        it("handles empty stream") {
          expect("stream-nothing.sh").toEventually(succeed(with: ""))
        }

        it("handles sleep") {
          expect("stream-sleep.sh").toEventually(succeed(with: ["A\n", "B\n"]))
        }
      }
    }

    describe("stderr") {
      describe("crash") {
        it("is missing shebang") {
          expect("missing-sh-bin.sh").toEventually(crash(with: "Couldn't posix_spawn: error 8"))
        }

        it("handles non-executable script") {
          expect("nonexec.sh").toEventually(crash(with: "launch path not accessible"))
        }

        it("handles non-executable script") {
          expect("does-not-exist.sh").toEventually(crash(with: "launch path not accessible"))
        }
      }

      describe("misuse") {
        it("handles invalid syntax") {
          expect("invalid-syntax.sh").toEventually(crash(misuse: "syntax error: unexpected end of file"))
        }
      }

      describe("status code") {
        it("exit code 1, no output") {
          expect("exit1-no-output.sh").toEventually(exit(with: "", andStatusCode: 1))
        }

        it("exit code 1, with output") {
          expect("exit1-output.sh").toEventually(exit(with: "Exit 1\n", andStatusCode: 1))
        }
      }
    }

    describe("actions") {
      let path = "sleep.sh"

      describe("autostart") {
        it("should not start automaticly if autostart = false") {
          expect((path, false, [])).toNotEventually(have(events: [.success]))
        }

        it("should start automaticly if autostart = true") {
          expect((path, true, [])).toEventually(have(events: [.success]))
        }
      }

      describe("stop") {
        it("should stop script and signal termination") {
          expect((path, true, [.stop])).toEventually(have(events: []))
          expect((path, true, [.stop])).toNotEventually(have(events: [.success]))
          expect((path, true, [.stop])).toNotEventually(have(events: [.termination]))
        }

        it("should be able to stop a non running script") {
          expect((path, false, [.stop])).toNotEventually(have(events: [.termination]))
          expect((path, false, [.stop])).toNotEventually(have(events: [.success]))
        }
      }

      describe("restart") {
        it("should terminate and start on restart") {
          expect((path, true, [.restart])).toEventually(have(events: [.success]))
          expect((path, true, [.restart])).toNotEventually(have(events: [.termination]))
        }
      }

      describe("start") {
        it("should only run once (autostart=false)") {
          expect((path, false, [.start, .start])).toEventually(have(events: [.success]))
        }

        it("should only run once (autostart=true)") {
          // expect((path, true, [.start, .start])).toEventually(have(events: [.success, .success]))
        }
      }
    }
  }
}
