import Quick
import Nimble
@testable import BitBar

class ContainerTests: Helper {
  override func spec() {
    var container: Container!
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

        it("has default trim") {
          expect(container.has(Trim(true))).to(beTrue())
        }

        it("has default emojize") {
          expect(container.has(Emojize(true))).to(beTrue())
        }

        describe("add()") {
          context("override (does not pre-existing)") {
            it("overrides dropdown") {
              container.add(param: Dropdown(false))
              expect(container.hasDropdown()).to(beFalse())
            }

            it("overrides terminal") {
              container.add(param: Terminal(false))
              expect(container.openTerminal()).to(beFalse())
            }

            it("overrides refresh") {
              container.add(param: Refresh(true))
              expect(container.shouldRefresh()).to(beTrue())
            }

            it("overrides refresh") {
              let named = NamedParam(key: "1", value: "X")
              container.add(param: named)
              expect(container.has(named)).to(beTrue())
            }
          }
        }

        describe("append()") {
          context("override (does not pre-existing)") {
            it("overrides dropdown") {
              container.append(params: [Dropdown(false)])
              expect(container.hasDropdown()).to(beFalse())
            }

            it("overrides terminal") {
              container.append(params: [Terminal(false)])
              expect(container.openTerminal()).to(beFalse())
            }

            it("overrides refresh") {
              container.append(params: [Refresh(true)])
              expect(container.shouldRefresh()).to(beTrue())
            }
          }

          context("filterParams & namedParams") {
            it("overrides trim") {
              // TODO: Move these
              var b1 = BoolVal(false)
              var b2 = BoolVal(false)
              expect(b1.bool == b2.bool).to(beTrue())

              b1 = BoolVal(true)
              b2 = BoolVal(true)
              expect(b1.bool == b2.bool).to(beTrue())

              b1 = BoolVal(false)
              b2 = BoolVal(true)
              expect(b1.bool == b2.bool).to(beFalse())

              b1 = BoolVal(true)
              b2 = BoolVal(false)
              expect(b1.bool == b2.bool).to(beFalse())

              let trim1 = Trim(true)
              container.append(params: [trim1])
              expect(container.has(trim1)).to(beTrue())

              let trim2 = Trim(false)
              container.append(params: [trim2])
              expect(container.has(trim2)).to(beTrue())
              expect(container.has(trim1)).to(beFalse())
            }

            it("overrides size") {
              let size1 = Size(5)
              container.append(params: [size1])
              expect(container.has(size1)).to(beTrue())

              let size2 = Size(2)
              container.append(params: [size2])
              expect(container.has(size2)).to(beTrue())
              expect(container.has(size1)).to(beFalse())
            }

            it("overrides font") {
              let font1 = Font("ABC")
              container.append(params: [font1])
              expect(container.has(font1)).to(beTrue())

              let font2 = Font("DEF")
              container.append(params: [font2])
              expect(container.has(font2)).to(beTrue())
              expect(container.has(font1)).to(beFalse())
            }

            it("overrides length") {
              let length1 = Length(5)
              container.append(params: [length1])
              expect(container.has(length1)).to(beTrue())

              let length2 = Length(10)
              container.append(params: [length2])
              expect(container.has(length2)).to(beTrue())
              expect(container.has(length1)).to(beFalse())
            }

            it("overrides equal names") {
              let named1 = NamedParam(key: "1", value: "Y")
              container.append(params: [named1])
              expect(container.has(named1)).to(beTrue())

              let named2 = NamedParam(key: "1", value: "Y")
              container.append(params: [named2])
              expect(container.has(named2)).to(beTrue())
              expect(container.has(named1)).to(beTrue())
            }
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
