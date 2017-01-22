//import Swift
//
//// Create a Task instance
//let task = Process()
//
//// Set the task parameters
//task.launchPath = "/usr/bin/env"
//task.arguments = ["ls", "-la"]
//
//// Create a Pipe and make the task
//// put all the output there
//let pipe = Pipe()
//task.standardOutput = pipe
//
//let outputHandle = pipe.fileHandleForReading
//outputHandle.waitForDataInBackgroundAndNotify()
//
//// When new data is available
//var dataAvailable: NSObjectProtocol!
//dataAvailable = NotificationCenter.defaultCenter.addObserver(forName: NSFileHandleDataAvailableNotification,
//    object: outputHandle, queue: nil) {  _ -> Void in
//        let data = pipe.fileHandleForReading.availableData
//        if data.count > 0 {
//            if let str = NSString(data: data, encoding: String.Encoding.utf8) {
//                print("Task sent some data: \(str)")
//            }
//            outputHandle.waitForDataInBackgroundAndNotify()
//        } else {
//            NotificationCenter.defaultCenter().removeObserver(dataAvailable)
//        }
//}
//
//// When task has finished
//var dataReady: NSObjectProtocol!
//dataReady = NotificationCenter.defaultCenter.addObserver(forName: NSTaskDidTerminateNotification,
//    object: pipe.fileHandleForReading, queue: nil) { _ -> Void in
//        print("Task terminated!")
//        NotificationCenter.defaultCenter().removeObserver(dataReady)
//}
//
//// Launch the task
//task.launch()
//
