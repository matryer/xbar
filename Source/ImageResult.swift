import AppKit

enum ImageResult {
  case data(Data)
  case image(NSImage)
  case error(String)
}
