import Quick
import Nimble
@testable import BitBar

class FileNameTests: Helper {
 override func spec() {
   describe("seconds") {
     it("handles base case") {
       self.match(File.parser, "aFile.10s.sh") {
         expect($0.0).to(equal("aFile"))
         expect(Int($0.1)).to(equal(10))
         expect($0.2).to(equal("sh"))
       }
     }
   }

   describe("minutes") {
     it("handles base case") {
       self.match(File.parser, "aFile.10m.sh") {
         expect($0.0).to(equal("aFile"))
         expect(Int($0.1)).to(equal(10 * 60))
         expect($0.2).to(equal("sh"))
       }
     }
   }

   describe("hours") {
     it("handles base case") {
       self.match(File.parser, "aFile.10h.sh") {
         expect($0.0).to(equal("aFile"))
         expect(Int($0.1)).to(equal(10 * 60 * 60))
         expect($0.2).to(equal("sh"))
       }
     }
   }

   describe("days") {
     it("handles base case") {
       self.match(File.parser, "aFile.10d.sh") {
         expect($0.0).to(equal("aFile"))
         expect(Int($0.1)).to(equal(10 * 60 * 60 * 24))
         expect($0.2).to(equal("sh"))
       }
     }
   }

   describe("failures") {
     it("failes on invalid unit") {
       self.failure(File.parser, "aFile.10X.sh")
     }

     it("failes on missing name") {
       self.failure(File.parser, "10d.sh")
     }

     it("failes on missing time") {
       self.failure(File.parser, "aFile.sh")
     }

     it("fails on missing ext") {
       self.failure(File.parser, "aFile.10d")
     }

     it("fails on negative unit") {
       self.failure(File.parser, "aFile.-10d.sh")
     }

     it("fails on empty name") {
       self.failure(File.parser, ".10d.sh")
     }

     it("fails on empty unit") {
       self.failure(File.parser, "aFile..sh")
     }

     it("fails on empty ext") {
       self.failure(File.parser, "aFile.10d.")
     }

     it("fails on no unit") {
       self.failure(File.parser, "aFile.10.sh")
     }

     it("fails on no time (with unit)") {
       self.failure(File.parser, "aFile.d.sh")
     }

     it("fails on more data (post)") {
       self.failure(File.parser, "aFile.d10.sh.X")
     }

     it("fails on more data (pre)") {
       self.failure(File.parser, "X.aFile.d10.sh")
     }
   }
 }
}
