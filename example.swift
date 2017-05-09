  class X: Hashable {
    var hashValue: Int {
            return 10
        }

        static func == (lhs: X, rhs: X) -> Bool {
            return false
        }
  }

class V {

}
// extension AnyObject: Hashable {
//   var hashValue: Int {
//           return 10
//       }
//
//       static func == (lhs: AnyObject, rhs: AnyObject) -> Bool {
//           return false
//       }
// }
  func xx(_ a:AnyClass) { print(3) }
  func xx<X: Hashable>(_ a: X) { print(1) }
  func xx<X>(_ a: X) { print(5) }
  // func xx(_ a:AnyObject) { print(2) }


  let x = X()
  let v = V()

  xx(x)
    xx(v)