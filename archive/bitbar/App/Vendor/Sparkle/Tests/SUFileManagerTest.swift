//
//  SUFileManagerTest.swift
//  Sparkle
//
//  Created by Mayur Pawashe on 9/26/15.
//  Copyright © 2015 Sparkle Project. All rights reserved.
//

import XCTest

class SUFileManagerTest: XCTestCase
{
    func makeTempFiles(testBlock: (SUFileManager, NSURL, NSURL, NSURL, NSURL, NSURL, NSURL) -> Void)
    {
        let fileManager = SUFileManager.defaultManager()
        
        let tempDirectoryURL = try! fileManager.makeTemporaryDirectoryWithPreferredName("Sparkle Unit Test Data", appropriateForDirectoryURL: NSURL(fileURLWithPath: NSHomeDirectory()))
        
        defer {
            try! fileManager.removeItemAtURL(tempDirectoryURL)
        }
        
        let ordinaryFileURL = tempDirectoryURL.URLByAppendingPathComponent("a file written by sparkles unit tests")
        try! "foo".dataUsingEncoding(NSUTF8StringEncoding)!.writeToURL(ordinaryFileURL, options: .DataWritingAtomic)
        
        let directoryURL = tempDirectoryURL.URLByAppendingPathComponent("a directory written by sparkles unit tests")
        try! NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: false, attributes: nil)
        
        let fileInDirectoryURL = directoryURL.URLByAppendingPathComponent("a file inside a directory written by sparkles unit tests")
        try! "bar baz".dataUsingEncoding(NSUTF8StringEncoding)!.writeToURL(fileInDirectoryURL, options: .DataWritingAtomic)
        
        let validSymlinkURL = tempDirectoryURL.URLByAppendingPathComponent("symlink test")
        try! NSFileManager.defaultManager().createSymbolicLinkAtURL(validSymlinkURL, withDestinationURL: directoryURL)
        
        let invalidSymlinkURL = tempDirectoryURL.URLByAppendingPathComponent("symlink test 2")
        try! NSFileManager.defaultManager().createSymbolicLinkAtURL(invalidSymlinkURL, withDestinationURL: tempDirectoryURL.URLByAppendingPathComponent("does not exist"))
        
        testBlock(fileManager, tempDirectoryURL, ordinaryFileURL, directoryURL, fileInDirectoryURL, validSymlinkURL, invalidSymlinkURL)
    }
    
    func testMoveFiles()
    {
        makeTempFiles() { fileManager, rootURL, ordinaryFileURL, directoryURL, fileInDirectoryURL, validSymlinkURL, invalidSymlinkURL in
            XCTAssertNil(try? fileManager.moveItemAtURL(ordinaryFileURL, toURL: directoryURL))
            XCTAssertNil(try? fileManager.moveItemAtURL(ordinaryFileURL, toURL: directoryURL.URLByAppendingPathComponent("foo").URLByAppendingPathComponent("bar")))
            XCTAssertNil(try? fileManager.moveItemAtURL(rootURL.URLByAppendingPathComponent("does not exist"), toURL: directoryURL))
            
            let newFileURL = (ordinaryFileURL.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("new file"))!
            try! fileManager.moveItemAtURL(ordinaryFileURL, toURL: newFileURL)
            XCTAssertFalse(fileManager._itemExistsAtURL(ordinaryFileURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(newFileURL))
            
            let newValidSymlinkURL = (ordinaryFileURL.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("new symlink"))!
            try! fileManager.moveItemAtURL(validSymlinkURL, toURL: newValidSymlinkURL)
            XCTAssertFalse(fileManager._itemExistsAtURL(validSymlinkURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(newValidSymlinkURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(directoryURL))
            
            let newInvalidSymlinkURL = (ordinaryFileURL.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("new invalid symlink"))!
            try! fileManager.moveItemAtURL(invalidSymlinkURL, toURL: newInvalidSymlinkURL)
            XCTAssertFalse(fileManager._itemExistsAtURL(invalidSymlinkURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(newValidSymlinkURL))
            
            let newDirectoryURL = (ordinaryFileURL.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("new directory"))!
            try! fileManager.moveItemAtURL(directoryURL, toURL: newDirectoryURL)
            XCTAssertFalse(fileManager._itemExistsAtURL(directoryURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(newDirectoryURL))
            XCTAssertFalse(fileManager._itemExistsAtURL(fileInDirectoryURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(newDirectoryURL.URLByAppendingPathComponent(fileInDirectoryURL.lastPathComponent!)))
        }
    }
    
    func testMoveFilesToTrash()
    {
        makeTempFiles() { fileManager, rootURL, ordinaryFileURL, directoryURL, fileInDirectoryURL, validSymlinkURL, invalidSymlinkURL in
            XCTAssertNil(try? fileManager.moveItemAtURLToTrash(rootURL.URLByAppendingPathComponent("does not exist")))
            
            let trashURL = try! NSFileManager.defaultManager().URLForDirectory(.TrashDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
            
            try! fileManager.moveItemAtURLToTrash(ordinaryFileURL)
            XCTAssertFalse(fileManager._itemExistsAtURL(ordinaryFileURL))
            
            let ordinaryFileTrashURL = trashURL.URLByAppendingPathComponent(ordinaryFileURL.lastPathComponent!)
            XCTAssertTrue(fileManager._itemExistsAtURL(ordinaryFileTrashURL))
            try! fileManager.removeItemAtURL(ordinaryFileTrashURL)
            
            let validSymlinkTrashURL = trashURL.URLByAppendingPathComponent(validSymlinkURL.lastPathComponent!)
            try! fileManager.moveItemAtURLToTrash(validSymlinkURL)
            XCTAssertTrue(fileManager._itemExistsAtURL(validSymlinkTrashURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(directoryURL))
            try! fileManager.removeItemAtURL(validSymlinkTrashURL)
            
            try! fileManager.moveItemAtURLToTrash(directoryURL)
            XCTAssertFalse(fileManager._itemExistsAtURL(directoryURL))
            XCTAssertFalse(fileManager._itemExistsAtURL(fileInDirectoryURL))
            
            let directoryTrashURL = trashURL.URLByAppendingPathComponent(directoryURL.lastPathComponent!)
            XCTAssertTrue(fileManager._itemExistsAtURL(directoryTrashURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(directoryTrashURL.URLByAppendingPathComponent(fileInDirectoryURL.lastPathComponent!)))
            
            try! fileManager.removeItemAtURL(directoryTrashURL)
        }
    }
    
    func testCopyFiles()
    {
        makeTempFiles() { fileManager, rootURL, ordinaryFileURL, directoryURL, fileInDirectoryURL, validSymlinkURL, invalidSymlinkURL in
            XCTAssertNil(try? fileManager.copyItemAtURL(ordinaryFileURL, toURL: directoryURL))
            XCTAssertNil(try? fileManager.copyItemAtURL(ordinaryFileURL, toURL: directoryURL.URLByAppendingPathComponent("foo").URLByAppendingPathComponent("bar")))
            XCTAssertNil(try? fileManager.copyItemAtURL(rootURL.URLByAppendingPathComponent("does not exist"), toURL: directoryURL))
            
            let newFileURL = (ordinaryFileURL.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("new file"))!
            try! fileManager.copyItemAtURL(ordinaryFileURL, toURL: newFileURL)
            XCTAssertTrue(fileManager._itemExistsAtURL(ordinaryFileURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(newFileURL))
            
            let newSymlinkURL = (ordinaryFileURL.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("new symlink file"))!
            try! fileManager.copyItemAtURL(invalidSymlinkURL, toURL: newSymlinkURL)
            XCTAssertTrue(fileManager._itemExistsAtURL(newSymlinkURL))
            
            let newDirectoryURL = (ordinaryFileURL.URLByDeletingLastPathComponent?.URLByAppendingPathComponent("new directory"))!
            try! fileManager.copyItemAtURL(directoryURL, toURL: newDirectoryURL)
            XCTAssertTrue(fileManager._itemExistsAtURL(directoryURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(newDirectoryURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(fileInDirectoryURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(newDirectoryURL.URLByAppendingPathComponent(fileInDirectoryURL.lastPathComponent!)))
        }
    }

    func testRemoveFiles()
    {
        makeTempFiles() { fileManager, rootURL, ordinaryFileURL, directoryURL, fileInDirectoryURL, validSymlinkURL, invalidSymlinkURL in
            XCTAssertNil(try? fileManager.removeItemAtURL(rootURL.URLByAppendingPathComponent("does not exist")))
            
            try! fileManager.removeItemAtURL(ordinaryFileURL)
            XCTAssertFalse(fileManager._itemExistsAtURL(ordinaryFileURL))
            
            try! fileManager.removeItemAtURL(validSymlinkURL)
            XCTAssertFalse(fileManager._itemExistsAtURL(validSymlinkURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(directoryURL))
            
            try! fileManager.removeItemAtURL(directoryURL)
            XCTAssertFalse(fileManager._itemExistsAtURL(directoryURL))
            XCTAssertFalse(fileManager._itemExistsAtURL(fileInDirectoryURL))
        }
    }
    
    func testReleaseFilesFromQuarantine()
    {
        makeTempFiles() { fileManager, rootURL, ordinaryFileURL, directoryURL, fileInDirectoryURL, validSymlinkURL, invalidSymlinkURL in
            try! fileManager.releaseItemFromQuarantineAtRootURL(ordinaryFileURL)
            try! fileManager.releaseItemFromQuarantineAtRootURL(directoryURL)
            try! fileManager.releaseItemFromQuarantineAtRootURL(validSymlinkURL)
            
            let quarantineData = "does not really matter what is here".cStringUsingEncoding(NSUTF8StringEncoding)!
            let quarantineDataLength = Int(strlen(quarantineData))
            
            XCTAssertEqual(0, setxattr(ordinaryFileURL.path!, SUAppleQuarantineIdentifier, quarantineData, quarantineDataLength, 0, XATTR_CREATE))
            XCTAssertGreaterThan(getxattr(ordinaryFileURL.path!, SUAppleQuarantineIdentifier, nil, 0, 0, XATTR_NOFOLLOW), 0)
            
            try! fileManager.releaseItemFromQuarantineAtRootURL(ordinaryFileURL)
            XCTAssertEqual(-1, getxattr(ordinaryFileURL.path!, SUAppleQuarantineIdentifier, nil, 0, 0, XATTR_NOFOLLOW))
            
            XCTAssertEqual(0, setxattr(directoryURL.path!, SUAppleQuarantineIdentifier, quarantineData, quarantineDataLength, 0, XATTR_CREATE))
            XCTAssertGreaterThan(getxattr(directoryURL.path!, SUAppleQuarantineIdentifier, nil, 0, 0, XATTR_NOFOLLOW), 0)
            
            XCTAssertEqual(0, setxattr(fileInDirectoryURL.path!, SUAppleQuarantineIdentifier, quarantineData, quarantineDataLength, 0, XATTR_CREATE))
            XCTAssertGreaterThan(getxattr(fileInDirectoryURL.path!, SUAppleQuarantineIdentifier, nil, 0, 0, XATTR_NOFOLLOW), 0)
            
            // Extended attributes can't be set on symbolic links currently
            try! fileManager.releaseItemFromQuarantineAtRootURL(validSymlinkURL)
            XCTAssertGreaterThan(getxattr(directoryURL.path!, SUAppleQuarantineIdentifier, nil, 0, 0, XATTR_NOFOLLOW), 0)
            XCTAssertEqual(-1, getxattr(validSymlinkURL.path!, SUAppleQuarantineIdentifier, nil, 0, 0, XATTR_NOFOLLOW))
            
            try! fileManager.releaseItemFromQuarantineAtRootURL(directoryURL)
            
            XCTAssertEqual(-1, getxattr(directoryURL.path!, SUAppleQuarantineIdentifier, nil, 0, 0, XATTR_NOFOLLOW))
            XCTAssertEqual(-1, getxattr(fileInDirectoryURL.path!, SUAppleQuarantineIdentifier, nil, 0, 0, XATTR_NOFOLLOW))
        }
    }
    
    func groupIDAtPath(path: String) -> gid_t
    {
        let attributes = try! NSFileManager.defaultManager().attributesOfItemAtPath(path)
        let groupID = attributes[NSFileGroupOwnerAccountID] as! NSNumber
        return groupID.unsignedIntValue
    }
    
    // Only the super user can alter user IDs, so changing user IDs is not tested here
    // Instead we try to change the group ID - we just have to be a member of that group
    func testAlterFilesGroupID()
    {
        makeTempFiles() { fileManager, rootURL, ordinaryFileURL, directoryURL, fileInDirectoryURL, validSymlinkURL, invalidSymlinkURL in
            XCTAssertNil(try? fileManager.changeOwnerAndGroupOfItemAtRootURL(ordinaryFileURL, toMatchURL: rootURL.URLByAppendingPathComponent("does not exist")))
            
            XCTAssertNil(try? fileManager.changeOwnerAndGroupOfItemAtRootURL(rootURL.URLByAppendingPathComponent("does not exist"), toMatchURL: ordinaryFileURL))
            
            let everyoneGroup = getgrnam("everyone")
            let everyoneGroupID = everyoneGroup.memory.gr_gid
            
            let staffGroup = getgrnam("staff")
            let staffGroupID = staffGroup.memory.gr_gid
            
            XCTAssertNotEqual(staffGroupID, everyoneGroupID)
            
            XCTAssertEqual(staffGroupID, self.groupIDAtPath(ordinaryFileURL.path!))
            XCTAssertEqual(staffGroupID, self.groupIDAtPath(directoryURL.path!))
            XCTAssertEqual(staffGroupID, self.groupIDAtPath(fileInDirectoryURL.path!))
            XCTAssertEqual(staffGroupID, self.groupIDAtPath(validSymlinkURL.path!))

            try! fileManager.changeOwnerAndGroupOfItemAtRootURL(fileInDirectoryURL, toMatchURL: ordinaryFileURL)
            try! fileManager.changeOwnerAndGroupOfItemAtRootURL(ordinaryFileURL, toMatchURL: ordinaryFileURL)
            try! fileManager.changeOwnerAndGroupOfItemAtRootURL(validSymlinkURL, toMatchURL: ordinaryFileURL)
            
            XCTAssertEqual(staffGroupID, self.groupIDAtPath(ordinaryFileURL.path!))
            XCTAssertEqual(staffGroupID, self.groupIDAtPath(directoryURL.path!))
            XCTAssertEqual(staffGroupID, self.groupIDAtPath(validSymlinkURL.path!))
            
            XCTAssertEqual(0, chown(ordinaryFileURL.path!, getuid(), everyoneGroupID))
            XCTAssertEqual(everyoneGroupID, self.groupIDAtPath(ordinaryFileURL.path!))
            
            try! fileManager.changeOwnerAndGroupOfItemAtRootURL(fileInDirectoryURL, toMatchURL: ordinaryFileURL)
            XCTAssertEqual(everyoneGroupID, self.groupIDAtPath(fileInDirectoryURL.path!))
            
            try! fileManager.changeOwnerAndGroupOfItemAtRootURL(fileInDirectoryURL, toMatchURL: directoryURL)
            XCTAssertEqual(staffGroupID, self.groupIDAtPath(fileInDirectoryURL.path!))
            
            try! fileManager.changeOwnerAndGroupOfItemAtRootURL(validSymlinkURL, toMatchURL: ordinaryFileURL)
            XCTAssertEqual(everyoneGroupID, self.groupIDAtPath(validSymlinkURL.path!))
            
            try! fileManager.changeOwnerAndGroupOfItemAtRootURL(directoryURL, toMatchURL: ordinaryFileURL)
            XCTAssertEqual(everyoneGroupID, self.groupIDAtPath(directoryURL.path!))
            XCTAssertEqual(everyoneGroupID, self.groupIDAtPath(fileInDirectoryURL.path!))
        }
    }
    
    func testUpdateFileModificationTime()
    {
        makeTempFiles() { fileManager, rootURL, ordinaryFileURL, directoryURL, fileInDirectoryURL, validSymlinkURL, invalidSymlinkURL in
            XCTAssertNil(try? fileManager.updateModificationAndAccessTimeOfItemAtURL(rootURL.URLByAppendingPathComponent("does not exist")))
            
            let oldOrdinaryFileAttributes = try! NSFileManager.defaultManager().attributesOfItemAtPath(ordinaryFileURL.path!)
            let oldDirectoryAttributes = try! NSFileManager.defaultManager().attributesOfItemAtPath(directoryURL.path!)
            let oldValidSymlinkAttributes = try! NSFileManager.defaultManager().attributesOfItemAtPath(validSymlinkURL.path!)
            
            sleep(1); // wait for clock to advance
            
            try! fileManager.updateModificationAndAccessTimeOfItemAtURL(ordinaryFileURL)
            try! fileManager.updateModificationAndAccessTimeOfItemAtURL(directoryURL)
            try! fileManager.updateModificationAndAccessTimeOfItemAtURL(validSymlinkURL)
            
            let newOrdinaryFileAttributes = try! NSFileManager.defaultManager().attributesOfItemAtPath(ordinaryFileURL.path!)
            XCTAssertGreaterThan((newOrdinaryFileAttributes[NSFileModificationDate] as! NSDate).timeIntervalSinceDate(oldOrdinaryFileAttributes[NSFileModificationDate] as! NSDate), 0)
            
            let newDirectoryAttributes = try! NSFileManager.defaultManager().attributesOfItemAtPath(directoryURL.path!)
            XCTAssertGreaterThan((newDirectoryAttributes[NSFileModificationDate] as! NSDate).timeIntervalSinceDate(oldDirectoryAttributes[NSFileModificationDate] as! NSDate), 0)
            
            let newSymlinkAttributes = try! NSFileManager.defaultManager().attributesOfItemAtPath(validSymlinkURL.path!)
            XCTAssertGreaterThan((newSymlinkAttributes[NSFileModificationDate] as! NSDate).timeIntervalSinceDate(oldValidSymlinkAttributes[NSFileModificationDate] as! NSDate), 0)
        }
    }
    
    func testFileExists()
    {
        makeTempFiles() { fileManager, rootURL, ordinaryFileURL, directoryURL, fileInDirectoryURL, validSymlinkURL, invalidSymlinkURL in
            XCTAssertTrue(fileManager._itemExistsAtURL(ordinaryFileURL))
            XCTAssertTrue(fileManager._itemExistsAtURL(directoryURL))
            XCTAssertFalse(fileManager._itemExistsAtURL(rootURL.URLByAppendingPathComponent("does not exist")))
            
            var isOrdinaryFileDirectory: ObjCBool = false
            XCTAssertTrue(fileManager._itemExistsAtURL(ordinaryFileURL, isDirectory: &isOrdinaryFileDirectory) && !isOrdinaryFileDirectory)
            
            var isDirectoryADirectory: ObjCBool = false
            XCTAssertTrue(fileManager._itemExistsAtURL(directoryURL, isDirectory: &isDirectoryADirectory) && isDirectoryADirectory)
            
            XCTAssertFalse(fileManager._itemExistsAtURL(rootURL.URLByAppendingPathComponent("does not exist"), isDirectory: nil))
            
            XCTAssertTrue(fileManager._itemExistsAtURL(validSymlinkURL))
            
            var validSymlinkIsADirectory: ObjCBool = false
            XCTAssertTrue(fileManager._itemExistsAtURL(validSymlinkURL, isDirectory: &validSymlinkIsADirectory) && !validSymlinkIsADirectory)
            
            // Symlink should still exist even if it doesn't point to a file that exists
            XCTAssertTrue(fileManager._itemExistsAtURL(invalidSymlinkURL))
            
            var invalidSymlinkIsADirectory: ObjCBool = false
            XCTAssertTrue(fileManager._itemExistsAtURL(invalidSymlinkURL, isDirectory: &invalidSymlinkIsADirectory) && !invalidSymlinkIsADirectory)
        }
    }
    
    func testMakeDirectory()
    {
        makeTempFiles() { fileManager, rootURL, ordinaryFileURL, directoryURL, fileInDirectoryURL, validSymlinkURL, invalidSymlinkURL in
            XCTAssertNil(try? fileManager.makeDirectoryAtURL(ordinaryFileURL))
            XCTAssertNil(try? fileManager.makeDirectoryAtURL(directoryURL))
            
            XCTAssertNil(try? fileManager.makeDirectoryAtURL(rootURL.URLByAppendingPathComponent("this should").URLByAppendingPathComponent("be a failure")))
            
            let newDirectoryURL = rootURL.URLByAppendingPathComponent("new test directory")
            XCTAssertFalse(fileManager._itemExistsAtURL(newDirectoryURL))
            try! fileManager.makeDirectoryAtURL(newDirectoryURL)
            
            var isDirectory: ObjCBool = false
            XCTAssertTrue(fileManager._itemExistsAtURL(newDirectoryURL, isDirectory: &isDirectory))
            
            try! fileManager.removeItemAtURL(directoryURL)
            XCTAssertNil(try? fileManager.makeDirectoryAtURL(validSymlinkURL))
        }
    }
    
    func testAcquireBadAuthorization()
    {
        let fileManager = SUFileManager.defaultManager()
        XCTAssertNil(try? fileManager._acquireAuthorization())
    }
}
