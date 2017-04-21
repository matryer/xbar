import SwiftCheck

protocol Base: class, Arbitrary, Equatable {
  func getInput() -> String
}
