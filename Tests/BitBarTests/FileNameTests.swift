import Quick
import Nimble
@testable import BitBar

class FileNameTests: Helper {
  override func spec() {
    describe("seconds") {
      it("handles base case") {
        self.match(Pro.getFile(), "aFile.10s.sh") {
          expect($0.name).to(equal("aFile"))
          expect($0.interval).to(equal(10))
          expect($0.ext).to(equal("sh"))
          expect($1).to(beEmpty())
        }
      }
    }

    describe("minutes") {
      it("handles base case") {
        self.match(Pro.getFile(), "aFile.10m.sh") {
          expect($0.name).to(equal("aFile"))
          expect($0.interval).to(equal(10 * 60))
          expect($0.ext).to(equal("sh"))
          expect($1).to(beEmpty())
        }
      }
    }

    describe("hours") {
      it("handles base case") {
        self.match(Pro.getFile(), "aFile.10h.sh") {
          expect($0.name).to(equal("aFile"))
          expect($0.interval).to(equal(10 * 60 * 60))
          expect($0.ext).to(equal("sh"))
          expect($1).to(beEmpty())
        }
      }
    }

    describe("days") {
      it("handles base case") {
        self.match(Pro.getFile(), "aFile.10d.sh") {
          expect($0.name).to(equal("aFile"))
          expect($0.interval).to(equal(10 * 60 * 60 * 24))
          expect($0.ext).to(equal("sh"))
          expect($1).to(beEmpty())
        }
      }
    }

    describe("failures") {
      it("failes on invalid unit") {
        self.failure(Pro.getFile(), "aFile.10X.sh")
      }

      it("failes on missing name") {
        self.failure(Pro.getFile(), "10d.sh")
      }

      it("failes on missing time") {
        self.failure(Pro.getFile(), "aFile.sh")
      }

      it("fails on missing ext") {
        self.failure(Pro.getFile(), "aFile.10d")
      }

      it("fails on negative unit") {
        self.failure(Pro.getFile(), "aFile.-10d.sh")
      }

      it("fails on empty name") {
        self.failure(Pro.getFile(), ".10d.sh")
      }

      it("fails on empty unit") {
        self.failure(Pro.getFile(), "aFile..sh")
      }

      it("fails on empty ext") {
        self.failure(Pro.getFile(), "aFile.10d.")
      }

      it("fails on no unit") {
        self.failure(Pro.getFile(), "aFile.10.sh")
      }

      it("fails on no time (with unit)") {
        self.failure(Pro.getFile(), "aFile.d.sh")
      }

      it("fails on more data (post)") {
        self.failure(Pro.getFile(), "aFile.d10.sh.X")
      }

      it("fails on more data (pre)") {
        self.failure(Pro.getFile(), "X.aFile.d10.sh")
      }
    }
  }
}
