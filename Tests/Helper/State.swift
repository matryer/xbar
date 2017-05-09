/* Used by verify() in Matcher.swift */
enum State {
  case bool(Bool, Any) /* ok, actual */
  case fail(Any) /* Actual */
}