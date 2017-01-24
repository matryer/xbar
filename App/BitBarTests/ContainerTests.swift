import Quick
import Nimble
@testable import BitBar

class ContainerTests: Helper {
  override func spec() {
    var container: Container!
    App.startedTesting()
    beforeEach {
      container = Container()
    }

    describe("container") {
      context("defaults") {
        it("has default refresh") {
          expect(container.shouldRefresh()).to(beFalse())
        }

        it("has default dropdown") {
          expect(container.hasDropdown()).to(beTrue())
        }

        it("has default terminal") {
          expect(container.openTerminal()).to(beTrue())
        }

        it("has default emojize") {
          let param = container.last(type: "Emojize")!
          expect(param is Emojize).to(beTrue())
          expect(param.equals(true)).to(beTrue())
        }

        it("has default trim") {
          let param = container.last(type: "Trim")!
          expect(param is Trim).to(beTrue())
          expect(param.equals(true)).to(beTrue())
        }

        context("override (does not pre-existing)") {
          var b1: Int!
          var b2: Int!
          var b3: Int!

          beforeEach {
            b1 = container.filterParams.count
            b2 = container.args.count
            b3 = container.params.count
          }

          afterEach {
            expect(container.filterParams).to(haveCount(b1 + 1))
            expect(container.args).to(haveCount(b2))
            expect(container.params).to(haveCount(b3 + 1))
          }

          it("overrides dropdown") {
            container.add(param: Dropdown(false))
            expect(container.shouldRefresh()).to(beFalse())
          }

          it("overrides terminal") {
            container.add(param: Terminal(false))
            expect(container.shouldRefresh()).to(beFalse())
          }

          it("overrides refresh") {
            container.add(param: Refresh(true))
            expect(container.shouldRefresh()).to(beTrue())
          }
        }

        context("override (does pre-existing)") {
          var b1: Int!
          var b2: Int!
          var b3: Int!

          beforeEach {
            b1 = container.filterParams.count
            b2 = container.args.count
            b3 = container.params.count
          }

          afterEach {
            expect(container.filterParams).to(haveCount(b1))
            expect(container.args).to(haveCount(b2))
            expect(container.params).to(haveCount(b3))
          }

          it("overrides emojize") {
            container.add(param: Emojize(false))
            let param = container.last(type: "Emojize")!
            expect(param.equals(false)).to(beTrue())
          }

          it("overrides trim") {
            container.add(param: Trim(false))
            let param = container.last(type: "Trim")!
            expect(param.equals(false)).to(beTrue())
          }
        }
      }

      context("named params") {
        it("defaults to an empty list") {
          expect(container.args).to(beEmpty())
        }

        it("sorts list") {
          let n1 = NamedParam(key: "2", value: "B")
          let n2 = NamedParam(key: "1", value: "A")
          let n3 = NamedParam(key: "0", value: "C")
          let beforeCount = container.filterParams.count

          container.append(params: [n1, n2])
          expect(container.args).to(equal(["A", "B"]))
          expect(container.namedParams).to(haveCount(2))
          expect(container.filterParams).to(haveCount(beforeCount))

          container.append(params: [n3])
          expect(container.args).to(equal(["C", "A", "B"]))
          expect(container.namedParams).to(haveCount(3))
          expect(container.filterParams).to(haveCount(beforeCount))
        }
      }
    }
  }
}
