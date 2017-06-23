import SwiftyBeaver
import WebSockets
// import SwiftyJSON

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
    // let json: SwiftyJSON.JSON = [
    //   "level": String(describing: level),
    //   "message": msg
    // ]
    //
    // let output = String(describing: json)
    // if (try? websocket.send(output)) == nil {
    //   log.error("Could not send data to connected socket server")
    // }
    //
    // return output
    return nil
  }
}
