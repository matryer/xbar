extension Paramable {
  var priority: Int { return 0 }
  public var description: String {
    return output
  }

  var output: String {
    return key + "=" + original
  }

  func equals(_ param: Paramable) -> Bool {
    return output == param.output
  }
}
