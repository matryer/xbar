import Foundation

extension String {
  func split(_ by: String) -> [String] {
    return components(separatedBy: by)
  }
}

extension String: Error {}
