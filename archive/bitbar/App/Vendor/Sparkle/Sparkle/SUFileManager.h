//
//  SUFileManager.h
//  Sparkle
//
//  Created by Mayur Pawashe on 7/18/15.
//  Copyright (c) 2015 zgcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A class used for performing file operations that may also perform authorization if allowed and if permission is denied when trying to
 * perform them normally as the running user. All operations on this class may be used on thread other than the main thread.
 * This class provides basic file operations and stays away from including much application-level logic.
 */
@interface SUFileManager : NSObject

/**
* Creates a file manager that will not authorize for file operations
* @return A new file manager instance
*/
+ (instancetype)defaultManager;

/**
 * Creates a file manager that allows authorizing for file operations
 * @param authorizationToolPath Specifies the path to the tool that can perform file operations and be run as root.
 * This tool will be invoked when read or write access is denied when attempting ordinary file operations. See the `fileop` tool included in Sparkle.
 * @return A new file manager instance
 *
 * This method just creates the file manager. It doesn't acquire authorization immediately or if it doesn't need to.
 */
+ (instancetype)fileManagerWithAuthorizationToolPath:(NSString *)authorizationToolPath;

/**
 * Returns a file manager that allows or disallows authorizing for file operations based on the current file manager
 * @return A file manager instance that can perform authorized operations if the current file manager has already performed them.
 *  If the current file manager instance hasn't yet performed authorized operations, then neither can the instance returned by this method
 *
 * This may return a newly created file manager or re-use the existing file manager depending on the current authorization rights.
 */
- (instancetype)fileManagerByPreservingAuthorizationRights;

/**
 * Creates a temporary directory on the same volume as a provided URL
 * @param preferredName A name that may be used when creating the temporary directory. Note that in the uncommon case this name is used, the temporary directory will be created inside the directory pointed by appropriateURL
 * @param appropriateURL A URL to a directory that resides on the volume that the temporary directory will be created on. In the uncommon case, the temporary directory may be created inside this directory.
 * @param error If an error occurs, upon returns contains an NSError object that describes the problem. If you are not interested in possible errors, you may pass in NULL.
 * @return A URL pointing to the newly created temporary directory, or nil with a populated error object if an error occurs.
 *
 * When moving an item from a source to a destination, it is desirable to create a temporary intermediate destination on the same volume as the destination to ensure
 * that the item will be moved, and not copied, from the intermediate point to the final destination. This ensures file atomicity.
 */
- (NSURL *)makeTemporaryDirectoryWithPreferredName:(NSString *)preferredName appropriateForDirectoryURL:(NSURL *)appropriateURL error:(NSError **)error;

/**
 * Creates a directory at the target URL
 * @param targetURL A URL pointing to the directory to create. The item at this URL must not exist, and the parent directory of this URL must already exist.
 * @param error If an error occurs, upon returns contains an NSError object that describes the problem. If you are not interested in possible errors, you may pass in NULL.
 * @return YES if the item was created successfully, otherwise NO along with a populated error object
 *
 * This is an atomic operation.
 */
- (BOOL)makeDirectoryAtURL:(NSURL *)targetURL error:(NSError **)error;

/**
 * Moves an item from a source to a destination
 * @param sourceURL A URL pointing to the item to move. The item at this URL must exist.
 * @param destinationURL A URL pointing to the destination the item will be moved at. An item must not already exist at this URL.
 * @param error If an error occurs, upon returns contains an NSError object that describes the problem. If you are not interested in possible errors, you may pass in NULL.
 * @return YES if the item was moved successfully, otherwise NO along with a populated error object
 * 
 * If sourceURL and destinationURL reside on the same volume, this operation will be an atomic move operation.
 * Otherwise this will be equivalent to a copy & remove which will be a nonatomic operation.
 */
- (BOOL)moveItemAtURL:(NSURL *)sourceURL toURL:(NSURL *)destinationURL error:(NSError **)error;

/**
 * Copies an item from a source to a destination
 * @param sourceURL A URL pointing to the item to move. The item at this URL must exist.
 * @param destinationURL A URL pointing to the destination the item will be moved at. An item must not already exist at this URL.
 * @param error If an error occurs, upon returns contains an NSError object that describes the problem. If you are not interested in possible errors, you may pass in NULL.
 * @return YES if the item was copied successfully, otherwise NO along with a populated error object
 *
 * This is not an atomic operation.
 */
- (BOOL)copyItemAtURL:(NSURL *)sourceURL toURL:(NSURL *)destinationURL error:(NSError **)error;

/**
 * Moves an item at a specified URL to the running user's trash directory
 * @param url A URL pointing to the item to move to the trash. The item at this URL must exist.
 * @param error If an error occurs, upon returns contains an NSError object that describes the problem. If you are not interested in possible errors, you may pass in NULL.
 * @return YES if the item was moved to the trash successfully, otherwise NO along with a populated error object
 *
 *
 * This method has to locate the trash directory and uses an intermediate temporary directory before trashing the item.
 * A copy may have to be done if the url is not on the same volume as the running user's trash directory.
 * If a failure occurs in the middle of this operation, the item to remove may be lost forever or stuck in a temporary location.
 * 
 * This is not an atomic operation, nor intended to be a recoverable operation if the worst comes to worst.
 */
- (BOOL)moveItemAtURLToTrash:(NSURL *)url error:(NSError **)error;

/**
 * Removes an item at a URL
 * @param url A URL pointing to the item to remove. The item at this URL must exist.
 * @param error If an error occurs, upon returns contains an NSError object that describes the problem. If you are not interested in possible errors, you may pass in NULL.
 * @return YES if the item was removed successfully, otherwise NO along with a populated error object
 *
 * This is not an atomic operation.
 */
- (BOOL)removeItemAtURL:(NSURL *)url error:(NSError **)error;

/**
 * Changes the owner and group IDs of an item at a specified target URL to match another URL
 * @param targetURL A URL pointing to the target item whose owner and group IDs to alter. This will be applied recursively if the item is a directory. The item at this URL must exist.
 * @param matchURL A URL pointing to the item whose owner and group IDs will be used for changing on the targetURL. The item at this URL must exist.
 * @param error If an error occurs, upon returns contains an NSError object that describes the problem. If you are not interested in possible errors, you may pass in NULL.
 * @return YES if the target item's owner and group IDs have changed to match the origin's ones, otherwise NO along with a populated error object
 *
 * If the owner and group IDs match on the root items of targetURL and matchURL, this method stops and assumes that nothing needs to be done.
 * Otherwise this method recursively changes the IDs if the target is a directory. If an item in the directory is encountered that is unable to be changed,
 * then this method stops and returns NO.
 *
 * This is not an atomic operation.
 */
- (BOOL)changeOwnerAndGroupOfItemAtRootURL:(NSURL *)targetURL toMatchURL:(NSURL *)matchURL error:(NSError **)error;

/**
 * Updates the modification and access time of an item at a specified target URL to the current time
 * @param targetURL A URL pointing to the target item whose modification and access time to update. The item at this URL must exist.
 * @param error If an error occurs, upon returns contains an NSError object that describes the problem. If you are not interested in possible errors, you may pass in NULL.
 * @return YES if the target item's modification and access times have been updated, otherwise NO along with a populated error object
 *
 * This method updates the modification and access time of an item to the current time, ideal for letting the system know we installed a new file or
 * application.
 *
 * This is not an atomic operation.
 */
- (BOOL)updateModificationAndAccessTimeOfItemAtURL:(NSURL *)targetURL error:(NSError **)error;

/**
 * Releases Apple's quarantine extended attribute from the item at the specified root URL
 * @param rootURL A URL pointing to the item to release from Apple's quarantine. This will be applied recursively if the item is a directory. The item at this URL must exist.
 * @param error If an error occurs, upon returns contains an NSError object that describes the problem. If you are not interested in possible errors, you may pass in NULL.
 * @return YES if all the items at the target could be released from quarantine, otherwise NO if any items couldn't along with a populated error object
 *
 * This method removes quarantine attributes from an item, ideally an application, so that when the user launches a new application themselves, they
 * don't have to witness the system dialog alerting them that they downloaded an application from the internet and asking if they want to continue.
 * Note that this may not exactly mimic the system behavior when a user opens an application for the first time (i.e, the xattr isn't deleted),
 * but this should be sufficient enough for our purposes.
 *
 * This method may return NO even if some items do get released from quarantine if the target URL is pointing to a directory.
 * Thus if an item cannot be released from quarantine, this method still continues on to the next enumerated item.
 *
 * This is not an atomic operation.
 */
- (BOOL)releaseItemFromQuarantineAtRootURL:(NSURL *)rootURL error:(NSError **)error;

/**
 * Runs an installer package (pkg) in a headless mode using /usr/sbin/installer
 * @param packageURL A URL pointing to the package to execute. The item at this URL must exist.
 * @param error If an error occurs, upon returns contains an NSError object that describes the problem. If you are not interested in possible errors, you may pass in NULL.
 * @return YES if the installer ran the package successfully, otherwise NO with a populated error object
 *
 * This method uses the system wide installer tool to run the provided package. This process does not show any UI, except for
 * an initial authorization prompt if the calling process does not have root privileges. In other words, root privileges are required to use this method, and the file manager instance must have been created by allowing authorization.
 * An error can occur if the package is unable to be ran by the installer, or if the installer reports a non-zero exit status code.
 */
- (BOOL)executePackageAtURL:(NSURL *)packageURL error:(NSError **)error;

@end
