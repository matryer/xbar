protocol Paramable: class, CustomStringConvertible {
  var priority: Int { get }
  var output: String { get } /* I.e: bash="/a/b/c.sh" */
  var key: String { get } /* I.e: bash */
  var original: String { get } /* I.e: "/a/b/c.sh" */
  var raw: String { get } /* I.e: /a/b/c.sh */
  func menu(didLoad: Menuable)
  func menu(didClick: Menuable)
  func equals(_ other: Paramable) -> Bool
}
