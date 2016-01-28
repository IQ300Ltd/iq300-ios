//
//  FileStore.m
//  Tayphoon
//
//  Created by Tayphoon on 21.12.12.
//  Copyright (c) 2012 Tayphoon. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>

#import "FileStore.h"
#import "NSError+Extension.h"

NSString * const FileStoreErrorDomain = @"FileStoreErrorDomain";

static FileStore * _sharedStore = nil;

@interface FileStore() {
    NSFileManager * _fileManager;
}

@property (strong, nonatomic) NSString *diskCachePath;
@property (strong, nonatomic) dispatch_queue_t ioQueue;

@end

@implementation FileStore

+ (FileStore *)sharedStore {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedStore = [[self alloc] initWithNamespace:@"Shared"];
    });
    
    return _sharedStore;
}

- (id)initWithNamespace:(NSString *)ns {
    self = [super init];
    
    if(self) {
        NSString * namespace = [@"com.tayphoon.FileStore." stringByAppendingString:ns];
        _ioQueue = dispatch_queue_create("com.tayphoon.FileStore", DISPATCH_QUEUE_SERIAL);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _diskCachePath = [paths[0] stringByAppendingPathComponent:namespace];
        
        dispatch_sync(_ioQueue, ^{
            _fileManager = [NSFileManager new];
        });
    }
    return self;
}

- (void)storeData:(NSData *)data forKey:(NSString *)key done:(FileStoreSaveDataToDiskHandler)doneBlock {
    [self storeData:data forFileName:[self storeFileNameForKey:key] done:doneBlock];
}

- (void)storeFileFromFileURL:(NSURL*)fileUrl forFileName:(NSString *)fileName done:(FileStoreSaveDataToDiskHandler)doneBlock {
    [self storeFileFromFileURL:fileUrl forKey:[self storeFileNameForKey:fileName] done:doneBlock];
}

- (NSString*)storeFileFromFileURL:(NSURL*)fileUrl forFileName:(NSString *)fileName error:(NSError**)error {
    NSString * key = [self storeFileNameForKey:fileName];
    if (![_fileManager fileExistsAtPath:_diskCachePath]) {
        [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:error];
    }
    
    if(error && *error) {
        return nil;
    }
    
    NSURL * destinationURL = [NSURL fileURLWithPath:[self.diskCachePath stringByAppendingPathComponent:key]];
    [_fileManager removeItemAtURL:destinationURL error:nil];
    
    if (![_fileManager moveItemAtURL:fileUrl toURL:destinationURL error:error]) {
        if(error) {
            NSLog(@"file move error: %@", *error);
            NSString * errorDescription = [NSString stringWithFormat:@"%s", strerror(errno)];
            *error = [NSError errorWithDomain:FileStoreErrorDomain
                                         code:errno
                                     userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
        }
    }

    return [self.diskCachePath stringByAppendingPathComponent:key];
}


- (BOOL)storeFileFromURL:(NSURL*)filePath atPath:(NSString*)destinationPath error:(NSError**)error {
    NSString * destinationDirectory = [destinationPath stringByDeletingLastPathComponent];
    NSError * rootError = [NSError errorWithDomain:FileStoreErrorDomain
                                              code:0
                                          userInfo:@{ NSLocalizedDescriptionKey: @"Move data failed" }];
    
    if (![_fileManager fileExistsAtPath:destinationDirectory]) {
        if(![_fileManager createDirectoryAtPath:destinationDirectory
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:error]) {
            *error = [rootError errorWithUnderlyingError:*error];
            return NO;
        }
    }
    
    NSURL * destinationURL = [NSURL fileURLWithPath:destinationPath];
    [_fileManager removeItemAtURL:destinationURL error:nil];
    
    if (![_fileManager moveItemAtURL:filePath toURL:destinationURL error:error]) {
        if(error) {
            NSString * errorDescription = [NSString stringWithFormat:@"%s", strerror(errno)];
            *error = [NSError errorWithDomain:FileStoreErrorDomain
                                         code:errno
                                     userInfo:@{ NSLocalizedDescriptionKey : errorDescription }];
            *error = [rootError errorWithUnderlyingError:*error];
        }
        return NO;
    }
    return YES;
}


- (void)storeFileFromFileURL:(NSURL*)fileUrl forKey:(NSString *)key done:(FileStoreSaveDataToDiskHandler)doneBlock {
    if (key && fileUrl) {
        if ([_fileManager fileExistsAtPath:fileUrl.path]) {
            void (^operationBlock)(void) = ^{
                NSError * error = nil;
                
                if (![_fileManager fileExistsAtPath:_diskCachePath]) {
                    [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:&error];
                }
                
                if(error) {
                    if(doneBlock) {
                        doneBlock(nil, error);
                    }
                    return;
                }
                
                NSURL * destinationURL = [NSURL fileURLWithPath:[self.diskCachePath stringByAppendingPathComponent:key]];
                [_fileManager removeItemAtURL:destinationURL error:nil];
                
                if (![_fileManager moveItemAtURL:fileUrl toURL:destinationURL error:&error]) {
                    NSLog(@"file move error: %@", error);
                    if(doneBlock) {
                        NSString * errorDescription = [NSString stringWithFormat:@"%s", strerror(errno)];
                        error = [NSError errorWithDomain:FileStoreErrorDomain
                                                    code:errno
                                                userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
                        
                        doneBlock(nil, error);
                    }
                }
                else if(doneBlock) {
                    doneBlock([self.diskCachePath stringByAppendingPathComponent:key], nil);
                }
            };
            
            dispatch_async(self.ioQueue, operationBlock);
        }
    }
}

- (void)storeData:(NSData *)data forFileName:(NSString *)fileName done:(FileStoreSaveDataToDiskHandler)doneBlock {
    if(data && fileName) {
        dispatch_async(self.ioQueue, ^ {
            NSError * error = nil;
            
            if (![_fileManager fileExistsAtPath:_diskCachePath]) {
                [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:&error];
            }
            
            if (!error && ![_fileManager createFileAtPath:[self.diskCachePath stringByAppendingPathComponent:fileName]
                                      contents:data
                                    attributes:nil]) {
                
                NSString * errorDescription = [NSString stringWithFormat:@"%s", strerror(errno)];
                error = [NSError errorWithDomain:FileStoreErrorDomain
                                            code:errno
                                        userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
            }
            
            if(doneBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    doneBlock((!error) ? fileName : nil, error);
                });
            }
        });
    }
}

- (void)queryDiskDataForKey:(NSString *)key done:(FileStoreQueryDiskDataHandler)doneBlock {
    [self queryDiskDataForFileName:[self storeFileNameForKey:key] done:doneBlock];
}

- (void)queryDiskDataForFileName:(NSString *)fileName done:(FileStoreQueryDiskDataHandler)doneBlock {
    if(doneBlock) {
        dispatch_async(self.ioQueue, ^ {
            @autoreleasepool {
                NSData * diskData = [NSData dataWithContentsOfFile:[self.diskCachePath stringByAppendingPathComponent:fileName]
                                                           options:NSDataReadingMappedAlways error:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    doneBlock(diskData);
                });
            }
        });
    }
}

- (BOOL)isDataStoredForKey:(NSString*)key {
    return [self isFileStoredNamed:[self storeFileNameForKey:key]];
}

- (BOOL)isFileStoredNamed:(NSString*)fileName {
    NSString * filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
    BOOL exists = [_fileManager fileExistsAtPath:filePath];
    
    return exists;
}

- (NSURL*)filePathURLForKey:(NSString*)key {
    NSString * filePath = [self filePathStringForKey:key];
    if([key length] > 0) {
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}

- (NSString*)filePathStringForKey:(NSString*)key {
    if([self isDataStoredForKey:key]) {
        NSString * filePath = [self.diskCachePath stringByAppendingPathComponent:[self storeFileNameForKey:key]];
        return filePath;
    }
    return nil;
}

- (NSString*)storeFilePathForURL:(NSString *)url {
    NSString * filePath = [self.diskCachePath stringByAppendingPathComponent:[self storeFileNameForKey:url]];
    return filePath;
}

- (void)removeDataForKey:(NSString *)key {
    [self removeDataForFileName:[self storeFileNameForKey:key]];
}

- (void)removeDataForFileName:(NSString *)fileName {
    dispatch_async(self.ioQueue, ^ {
        [_fileManager removeItemAtPath:[self.diskCachePath stringByAppendingPathComponent:fileName]
                                 error:nil];
    });
}

- (void)clearDisk {
    dispatch_async(self.ioQueue, ^ {
        [_fileManager removeItemAtPath:self.diskCachePath error:nil];
        [_fileManager createDirectoryAtPath:self.diskCachePath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:NULL];
    });
}

- (NSUInteger)getSize {
    __block NSUInteger size = 0;
    dispatch_sync(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.diskCachePath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [_fileManager attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}

- (NSUInteger)getDiskCount {
    __block NSUInteger count = 0;
    dispatch_sync(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:self.diskCachePath];
        count = [[fileEnumerator allObjects] count];
    });
    return count;
}

- (NSString *)storeFileNameForKey:(NSString *)key {
    if(key) {
        const char *str = [key UTF8String];
        unsigned char r[CC_MD5_DIGEST_LENGTH];
        CC_MD5(str, (CC_LONG)strlen(str), r);
        NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                              r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
        
        NSString * pathExtension = key.pathExtension;
        if([pathExtension length] != 0) {
            filename = [filename stringByAppendingPathExtension:pathExtension];
        }
        return filename;
    }
    return  nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _ioQueue = nil;
}

@end
