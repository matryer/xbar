extension String {
  func withArgs(_ args: [String]) -> (String, [String]) {
    return (self, args)
  }
}
