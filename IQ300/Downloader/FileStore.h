//
//  FileStore.h
//  Tayphoon
//
//  Created by Tayphoon on 21.12.12.
//  Copyright (c) 2012 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const FileStoreErrorDomain;

typedef void(^FileStoreQueryDiskDataHandler)(NSData * data);
typedef void(^FileStoreSaveDataToDiskHandler)(NSString * filePath, NSError * error);

@interface FileStore : NSObject

+ (FileStore *)sharedStore;

/**
 * The maximum length of time to keep an data in the store, in seconds
 */
@property (assign, nonatomic) NSInteger maxStoreAge;

/**
 * Init a new file store with a specific namespace
 *
 * @param ns The namespace to use for this file store
 */
- (id)initWithNamespace:(NSString *)ns;

/**
 * Store an data into disk at the given key.
 *
 * @param data The data to store
 * @param key The unique data file key, usually it's data file absolute URL
 */
- (void)storeData:(NSData *)data forKey:(NSString *)key done:(FileStoreSaveDataToDiskHandler)doneBlock;

/**
 * Store an data into disk at the given key.
 *
 * @param data The data to store
 * @param fileName The unique data file name
 */
- (void)storeData:(NSData *)data forFileName:(NSString *)fileName done:(FileStoreSaveDataToDiskHandler)doneBlock;

/**
 * Move file from URL to internal storage
 */
- (void)storeFileFromFileURL:(NSURL*)fileUrl forFileName:(NSString *)fileName done:(FileStoreSaveDataToDiskHandler)doneBlock;

/**
 * Move file from URL to internal storage
 *
 * @return Saved file name
 */
- (NSString*)storeFileFromFileURL:(NSURL*)fileUrl forFileName:(NSString *)fileName error:(NSError**)error;

/**
 * Move file from @filePath to @destinationPath(may locate not in internal storage). Helper method.
 *
 * @completion Moved file data
 */

- (BOOL)storeFileFromURL:(NSURL*)filePath atPath:(NSString*)destinationPath error:(NSError**)error;

/**
 * Query the disk data asynchronousely.
 *
 * @param key The unique key used to store the wanted data
 */
- (void)queryDiskDataForKey:(NSString *)key done:(FileStoreQueryDiskDataHandler)doneBlock;

/**
 * Query the disk data asynchronousely.
 *
 * @param fileName The unique data file name
 */
- (void)queryDiskDataForFileName:(NSString *)fileName done:(FileStoreQueryDiskDataHandler)doneBlock;

- (BOOL)isDataStoredForKey:(NSString*)key;

- (BOOL)isFileStoredNamed:(NSString*)fileName;

- (NSURL*)filePathURLForKey:(NSString*)key;

/**
 * StoreFilePathForURL.
 *
 * @return File path for url in internal storage.
 */

- (NSString *)storeFilePathForURL:(NSString*)url;

/**
 * Remove the data from disk synchronousely
 *
 * @param key The unique data file key
 */
- (void)removeDataForKey:(NSString *)key;

/**
 * Remove the data from disk synchronousely
 *
 * @param fileName The unique data file name
 */
- (void)removeDataForFileName:(NSString *)fileName;

/**
 * Clear all stored files from disk
 */
- (void)clearDisk;

/**
 * Get the size used by the disk store
 */
- (NSUInteger)getSize;

/**
 * Get the number of data files in the disk store
 */
- (NSUInteger)getDiskCount;

- (NSString*)filePathStringForKey:(NSString*)key;

@end
