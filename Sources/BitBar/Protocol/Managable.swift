protocol Managable: class, Parent {
  func plugin(didReceiveOutput: String)
  func plugin(didReceiveError: String)
}
