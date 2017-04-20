// import EmitterKit
//
// /**
//   Represents zero or more params for a title or menu
// */
// final class Container: Equatable {
//   private var listener: Listener?
//   // private var namedStore = [Int: NamedParam]()
//   // private var filterStore = [String: Param<Any>]()
//   // internal var namedParams: [NamedParam] {
//   //   return [NamedParam]()
//   //   // return Array(namedStore.values)
//   // }
//   // internal var filterParams: [Param<Any>] {
//   //   // return Array(filterStore.values).sorted {
//   //   //   return $0.priority > $1.priority
//   //   // }
//   //   return [Param<Any>]
//   // }
//   internal weak var delegate: Menuable? {
//     didSet { self.handleDelegate() }
//   }
//
//   /**
//     A non sorted list of all params
//     I.e terminal=false, param7=2
//   */
//   var params: [Param<Any>] {
//     // TODO: Fix me
//     // return filterParams
//     return [Param<Any>]()
// //    return namedParams + filterParams
//   }
//
//   /**
//     Params to be passed as argument to a bash script
//     Sorted. I.e param2="A", param1="B"
//     Becomes ["B", "A"]
//   */
//   var args: [String] {
//     // return namedParams.sorted {
//     //   return $0.index < $1.index
//     // }.map { $0.value }
//     return ["A"]
//   }
//
//   init(params: [Param<Any>] = []) {
//     /* Defaults */
//     // add(param: Emojize(true))
//     // add(param: Trim(true))
//     // add(param: Dropdown(true))
//     // add(param: Refresh(false))
//     // add(param: Terminal(true))
//     //
//     // /* User defined */
//     // append(params: params)
//     self.params = params
//   }
//
// //   /**
// //     Does the container contain @param?
// //   */
// //   func has<T: Paramable>(_ param: T) -> Bool {
// //     return params.reduce(false) { $0 || $1.equals(param.value) }
// //   }
// //
// //   /**
// //     Add @params to the collection
// //   */
// //   func append<T: Paramable>(params: [T]) {
// //     for param in params {
// //       add(param: param)
// //     }
// //   }
// //
// // //  /**
// // //    Add @param to internal storage
// // //    Used to generate the args list to a bash script
// // //  */
// // //  func add(param: NamedParam) {
// // //    namedStore[param.index] = param
// // //  }
// //
// //   /**
// //     Add @param to internal storage
// //     The param is later applied to @delegate
// //   */
// //   func add<T: Paramable>(param: T) {
// //     switch param {
// //     case is NamedParam:
// //       namedStore[(param as! NamedParam).index] = param as! NamedParam
// //     case is Param<Any>:
// //       filterStore[param.key] = param as! Param<Any>
// //     default:
// //       preconditionFailure("Failed: (TODO: better error)")
// //     }
// //   }
// //
// //   /**
// //     Represents the refresh param, i.e refresh=false
// //   */
// //   func shouldRefresh() -> Bool {
// //     // TODO: Make static
// //     return has(Refresh(true))
// //   }
// //
// //   /**
// //     Represents the dropdown param, i.e dropdown=false
// //   */
// //   func hasDropdown() -> Bool {
// //     return has(Dropdown(true))
// //   }
// //
// //   /**
// //     Represents the terminal param, i.e terminal=false
// //   */
// //   func openTerminal() -> Bool {
// //     return has(Terminal(true))
// //   }
// //
// //   // Implements Equatable
// //   static func == (_ lhs: Container, _ rhs: Container) -> Bool {
// //     if lhs.params.count != rhs.params.count {
// //       return false
// //     }
// //
// //     for param in lhs.params {
// //       if !rhs.has(param) {
// //         return false
// //       }
// //     }
// //
// //     if lhs.args != rhs.args {
// //       return false
// //     }
// //
// //     if lhs.args.count != rhs.args.count {
// //       return false
// //     }
// //
// //     switch (lhs.delegate, rhs.delegate) {
// //     case (.some(_), .some(_)):
// //       break /* TODO: compare the two */
// //     case (.none, .none):
// //       break /* OK */
// //     default:
// //       return false
// //     }
// //
// //     return true
// //   }
// //
//   // Bind events to newly set delegate
//   // Removes listener, if delegate is nil
//   private func handleDelegate() {
//     let params = self.filterParams
//     if let menu = delegate {
//       for param in params {
//         param.menu(didLoad: menu)
//       }
//
//       listener = menu.onDidClick {
//         for param in params {
//           param.menu(didClick: menu)
//         }
//       }
//     } else {
//       listener = nil
//     }
//   }
// }
