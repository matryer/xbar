extension String {
  /**
   Replace @what with @with in @self
   */
  func replace(_ what: String, _ with: String) -> String {
    return replacingOccurrences(of: what, with: with, options: .literal, range: nil)
  }

  func inspected() -> String {
    return "\"" + replace("\n", "↵").replace("\0", "0") + "\""
  }

  func unescaped(quote: String = "\"") -> String {
    return replace("\\\\", "\\").replace("\\" + quote, quote)
  }
}
