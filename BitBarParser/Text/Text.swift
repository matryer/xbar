struct Text {
  let title: String
  let params: [Param]

  var isSeparator: Bool {
    return title == "-"
  }

  func set(text: String) -> Text {
    return Text(title: title, params: params)
  }

  func add(param: Param) -> Text {
    return Text(title: title, params: params + [param])
  }
}
