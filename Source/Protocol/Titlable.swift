import Foundation
import Emojize
import BonMot

typealias Immutable = NSAttributedString
let barFont = FontType.bar.font
let barWarn = ":warning:".emojified.styled(
  with: StringStyle(
    .font(barFont),
    .baselineOffset(-1)
  )
)

let menuFont = FontType.item.font
let menuWarn = ":warning:".emojified.styled(
  with: StringStyle(
    .font(menuFont),
    .baselineOffset(-1)
  )
)

protocol Titlable: Parent {
  var originalTitle: Immutable? { get set }
  var attributedTitle: Immutable? { get set }
  var warningLabel: Immutable { get }
  var textFont: NSFont { get }
  func set(error message: String)
  func set(error message: Immutable, broadcast: Bool)
  func set(title: String)
  func set(title: Immutable)
  func set(error: Bool)
}

extension Titlable {
  func set(error message: String) {
    set(error: message.immutable)
  }

  func set(error message: Immutable, broadcast bc: Bool = true) {
    originalTitle = message
    attributedTitle = NSAttributedString.composed(of: [
      warningLabel,
      Special.noBreakSpace,
      message.styled(with: .font(textFont), .baselineOffset(-1))
    ])
    if bc { broadcast(.didSetError) }
  }

  func set(title: String) {
    set(title: title.immutable.styled(with: .font(textFont)))
  }

  func set(title: Immutable) {
    originalTitle = title
    attributedTitle = title
  }

  func set(error: Bool) {
    if let title = originalTitle {
      if error {
        set(error: title, broadcast: false)
      } else {
        set(title: title)
      }
    }
  }
}
