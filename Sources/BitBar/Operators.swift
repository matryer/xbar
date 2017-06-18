import BonMot

func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
  return NSAttributedString.composed(of: [lhs, rhs])
}
