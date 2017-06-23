import SwiftyBeaver
import WebSockets
import JSON

public class SocketLog: BaseDestination {
  private let websocket: WebSocket
  private let log: SwiftyBeaver.Type

  init(_ ws: WebSocket, _ log: SwiftyBeaver.Type) {
    self.websocket = ws
    self.log = log
    super.init()
  }

  override public func send(_ level: SwiftyBeaver.Level, msg: String, thread: String,
                            file: String, function: String, line: Int) -> String? {
    var json = JSON()
    do {
      try json.set("level", String(describing: level))
      try json.set("message", msg)
    } catch {
      return "[Fatal error] Could not create log message \(error)"
    }


    guard let bytes = try? json.serialize(prettyPrint: true) else {
      return "[Fatal error] Could not serialize json"
    }

    let data = NSData(bytes: bytes, length: bytes.count) as Data
    guard let output = String(data: data, encoding: .utf8) else {
      return nil
    }

    guard (try? websocket.send(output)) != nil else {
      return "[Fatal error] Could not send data to connected socket server"
    }

    return output
  }
}
