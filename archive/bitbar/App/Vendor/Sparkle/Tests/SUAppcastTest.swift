//
//  SUAppcastTest.swift
//  Sparkle
//
//  Created by Kornel on 17/02/2016.
//  Copyright © 2016 Sparkle Project. All rights reserved.
//

import XCTest
import Sparkle;

class SUAppcastTest: XCTestCase {

    func testParseAppcast() {
        let appcast = SUAppcast();
        let testFile = NSBundle(forClass: SUAppcastTest.self).pathForResource("testappcast", ofType: "xml")!;
        let testFileUrl = NSURL(fileURLWithPath: testFile);
        XCTAssertNotNil(testFileUrl);
        
        do {
            let items = try appcast.parseAppcastItemsFromXMLFile(testFileUrl) as! [SUAppcastItem];
            
            XCTAssertEqual(4, items.count);
            
            XCTAssertEqual("Version 2.0", items[0].title);
            XCTAssertEqual("desc", items[0].itemDescription);
            XCTAssertEqual("Sat, 26 Jul 2014 15:20:11 +0000", items[0].dateString)
            
            // This is the best release matching our system version
            XCTAssertEqual("Version 3.0", items[1].title);
            XCTAssertNil(items[1].itemDescription);
            XCTAssertNil(items[1].dateString)
            
            XCTAssertEqual("Version 4.0", items[2].title);
            XCTAssertNil(items[2].itemDescription);
            XCTAssertEqual("Sat, 26 Jul 2014 15:20:13 +0000", items[2].dateString)
            
            XCTAssertEqual("Version 5.0", items[3].title);
            XCTAssertNil(items[3].itemDescription);
            XCTAssertNil(items[3].dateString)
            
            // Test best appcast item & a delta update item
            var deltaItem: SUAppcastItem? = nil
            let bestAppcastItem = SUBasicUpdateDriver.bestItemFromAppcastItems(items, getDeltaItem: &deltaItem, withHostVersion: "1.0", comparator: SUStandardVersionComparator.defaultComparator())

            XCTAssertEqual(bestAppcastItem, items[1])
            XCTAssertEqual(deltaItem!.fileURL.lastPathComponent, "3.0_from_1.0.patch")
            
            // Test latest delta update item available
            var latestDeltaItem: SUAppcastItem? = nil
            SUBasicUpdateDriver.bestItemFromAppcastItems(items, getDeltaItem: &latestDeltaItem, withHostVersion: "2.0", comparator: SUStandardVersionComparator.defaultComparator())
            
            XCTAssertEqual(latestDeltaItem!.fileURL.lastPathComponent, "3.0_from_2.0.patch")
            
            // Test a delta item that does not exist
            var nonexistantDeltaItem: SUAppcastItem? = nil
            SUBasicUpdateDriver.bestItemFromAppcastItems(items, getDeltaItem: &nonexistantDeltaItem, withHostVersion: "2.1", comparator: SUStandardVersionComparator.defaultComparator())
            
            XCTAssertNil(nonexistantDeltaItem)
        } catch let err as NSError {
            NSLog("%@", err);
            XCTFail(err.localizedDescription);
        }
    }

    func testNamespaces() {
        let appcast = SUAppcast();
        let testFile = NSBundle(forClass: SUAppcastTest.self).pathForResource("testnamespaces", ofType: "xml")!;
        let testFileUrl = NSURL(fileURLWithPath: testFile);
        XCTAssertNotNil(testFileUrl);

        do {
            let items = try appcast.parseAppcastItemsFromXMLFile(testFileUrl) as! [SUAppcastItem];

            XCTAssertEqual(2, items.count);

            XCTAssertEqual("Version 2.0", items[1].title);
            XCTAssertEqual("desc", items[1].itemDescription);
            XCTAssertNotNil(items[0].releaseNotesURL);
            XCTAssertEqual("https://sparkle-project.org/#works", items[0].releaseNotesURL!.absoluteString);
        } catch let err as NSError {
            NSLog("%@", err);
            XCTFail(err.localizedDescription);
        }
    }

}
