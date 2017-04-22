/* Just a placeholder, see Param#before and Param#after */
class All: Param<String> {
  override init(_: String) {
    preconditionFailure("Should not be called")
  }
}

let Everyone = [All.self]
