#!/usr/bin/xcrun swift

import Foundation

func die(msg: String) {
    print("ERROR: \(msg)")
    exit(1)
}

extension NSXMLElement {
    convenience init(name: String, attributes: [String: String], stringValue string: String? = nil) {
        self.init(name: name, stringValue: string)
        setAttributesWithDictionary(attributes)
    }
}

let ud = NSUserDefaults.standardUserDefaults()
let sparkleRoot = ud.objectForKey("root") as? String
let htmlPath = ud.objectForKey("htmlPath") as? String
if sparkleRoot == nil || htmlPath == nil {
    die("Missing arguments")
}

let enStringsPath = sparkleRoot! + "/Sparkle/en.lproj/Sparkle.strings"
let enStringsDict = NSDictionary(contentsOfFile: enStringsPath)
if enStringsDict == nil {
    die("Invalid English strings")
}
let enStringsDictKeys = enStringsDict!.allKeys

let dirPath = NSString(string: sparkleRoot! + "/Sparkle")
let dirContents = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(dirPath as String)
let css =
    "body { font-family: sans-serif; font-size: 10pt; }" +
    "h1 { font-size: 12pt; }" +
    ".missing { background-color: #FFBABA; color: #D6010E; white-space: pre; }" +
    ".unused { background-color: #BDE5F8; color: #00529B; white-space: pre; }" +
    ".unlocalized { background-color: #FEEFB3; color: #9F6000; white-space: pre; }"
var html = NSXMLDocument(rootElement: NSXMLElement(name: "html"))
html.DTD = NSXMLDTD()
html.DTD!.name = html.rootElement()!.name
html.characterEncoding = "UTF-8"
html.documentContentKind = NSXMLDocumentContentKind.XHTMLKind
var body = NSXMLElement(name: "body")
var head = NSXMLElement(name: "head")
html.rootElement()!.addChild(head)
html.rootElement()!.addChild(body)
head.addChild(NSXMLElement(name: "meta", attributes: ["charset": html.characterEncoding!]))
head.addChild(NSXMLElement(name: "title", stringValue: "Sparkle Localizations Report"))
head.addChild(NSXMLElement(name: "style", stringValue: css))

let locale = NSLocale.currentLocale()
for dirEntry in dirContents {
    if NSString(string: dirEntry).pathExtension != "lproj" || dirEntry == "en.lproj" {
        continue
    }

    let lang = locale.displayNameForKey(NSLocaleLanguageCode, value: NSString(string: dirEntry).stringByDeletingPathExtension)
    body.addChild(NSXMLElement(name: "h1", stringValue: "\(dirEntry) (\(lang!))"))

    let stringsPath = NSString(string: dirPath.stringByAppendingPathComponent(dirEntry)).stringByAppendingPathComponent("Sparkle.strings")
    let stringsDict = NSDictionary(contentsOfFile: stringsPath)
    if stringsDict == nil {
        die("Invalid strings file \(dirEntry)")
        continue
    }

    var missing: [String] = []
    var unlocalized: [String] = []
    var unused: [String] = []

    for key in enStringsDictKeys {
        let str = stringsDict?.objectForKey(key) as? String
        if str == nil {
            missing.append(key as! String)
        } else if let enStr = enStringsDict?.objectForKey(key) as? String {
            if enStr == str {
                unlocalized.append(key as! String)
            }
        }
    }

    let stringsDictKeys = stringsDict!.allKeys
    for key in stringsDictKeys {
        if enStringsDict?.objectForKey(key) == nil {
            unused.append(key as! String)
        }
    }

    let sorter = { (s1: String, s2: String) -> Bool in
        return s1 < s2
    }
    missing.sortInPlace(sorter)
    unlocalized.sortInPlace(sorter)
    unused.sortInPlace(sorter)

    let addRow = { (prefix: String, cssClass: String, key: String) -> Void in
        body.addChild(NSXMLElement(name: "span", attributes: ["class": cssClass], stringValue: [prefix, key].joinWithSeparator(" ") + "\n"))
    }

    for key in missing {
        addRow("Missing", "missing", key)
    }
    for key in unlocalized {
        addRow("Unlocalized", "unlocalized", key)
    }
    for key in unused {
        addRow("Unused", "unused", key)
    }
}

var err: NSError?
if !html.XMLData.writeToFile(htmlPath!, atomically: true) {
    die("Can't write report: \(err)")
}
