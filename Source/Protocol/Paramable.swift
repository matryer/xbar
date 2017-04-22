protocol Paramable: class, CustomStringConvertible {
  var before: Filter { get } /* I.e [Terminal.self] */
  var after: Filter { get } /* I.e [Terminal.self] */
  var output: String { get } /* I.e: bash="/a/b/c.sh" */
  var key: String { get } /* I.e: bash */
  var original: String { get } /* I.e: "/a/b/c.sh" */
  var raw: String { get } /* I.e: /a/b/c.sh */
  func menu(didLoad: Menuable) /* Called when menu has been instantiated */
  func menu(didClick: Menuable) /* Called when a user clicks on the menu */
  /* Anyc version of the above */
  func menu(didClick menu: Menuable, done: @escaping (String?) -> Void)
}

