//
//  SUUnarchiverTest.swift
//  Sparkle
//
//  Created by Mayur Pawashe on 9/4/15.
//  Copyright © 2015 Sparkle Project. All rights reserved.
//

import XCTest

class SUUnarchiverTest: XCTestCase, SUUnarchiverDelegate
{
    var password: String? = nil
    var unarchivedExpectation: XCTestExpectation? = nil
    var unarchivedResult: Bool = false
    
    func unarchiver(unarchiver: SUUnarchiver!, extractedProgress progress: Double)
    {
    }
    
    func unarchiverDidFail(unarchiver: SUUnarchiver!)
    {
        self.unarchivedResult = false
        self.unarchivedExpectation!.fulfill()
    }
    
    func unarchiverDidFinish(unarchiver: SUUnarchiver!)
    {
        self.unarchivedResult = true
        self.unarchivedExpectation!.fulfill()
    }
    
    func unarchiveTestAppWithExtension(archiveExtension: String)
    {
        let appName = "SparkleTestCodeSignApp"
        let archiveResourceURL = NSBundle(forClass: self.dynamicType).URLForResource(appName, withExtension: archiveExtension)!
        
        let fileManager = NSFileManager.defaultManager()
        
        let tempDirectoryURL = try! fileManager.URLForDirectory(.ItemReplacementDirectory, inDomain: .UserDomainMask, appropriateForURL: NSURL(fileURLWithPath: NSHomeDirectory()), create: true)
        defer {
            try! fileManager.removeItemAtURL(tempDirectoryURL)
        }
        
        let tempArchiveURL = tempDirectoryURL.URLByAppendingPathComponent(archiveResourceURL.lastPathComponent!)
        let extractedAppURL = tempDirectoryURL.URLByAppendingPathComponent(appName).URLByAppendingPathExtension("app")
        
        try! fileManager.copyItemAtURL(archiveResourceURL, toURL: tempArchiveURL)
        
        self.unarchivedExpectation = super.expectationWithDescription("Unarchived Application (format: \(archiveExtension))")
        
        let unarchiver = SUUnarchiver(forPath: tempArchiveURL.path!, updatingHostBundlePath: nil, withPassword: self.password)

        unarchiver.delegate = self
        unarchiver.start()
        
        super.waitForExpectationsWithTimeout(7.0, handler: nil)
        
        XCTAssertTrue(self.unarchivedResult)
        XCTAssertTrue(fileManager.fileExistsAtPath(extractedAppURL.path!))
        
        XCTAssertEqual("6a60ab31430cfca8fb499a884f4a29f73e59b472", hashOfTree(extractedAppURL.path!))
    }

    func testUnarchivingZip()
    {
        self.unarchiveTestAppWithExtension("zip")
    }
    
    func testUnarchivingTarDotGz()
    {
        self.unarchiveTestAppWithExtension("tar.gz")
    }
    
    func testUnarchivingTar()
    {
        self.unarchiveTestAppWithExtension("tar")
    }
    
    func testUnarchivingTarDotBz2()
    {
        self.unarchiveTestAppWithExtension("tar.bz2")
    }
    
    func testUnarchivingTarDotXz()
    {
        self.unarchiveTestAppWithExtension("tar.xz")
    }
    
    func testUnarchivingDmg()
    {
        self.unarchiveTestAppWithExtension("dmg")
    }

    func testUnarchivingEncryptedDmg()
    {
        self.password = "testpass";
        self.unarchiveTestAppWithExtension("enc.dmg")
    }
}
