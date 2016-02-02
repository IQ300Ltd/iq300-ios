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
    NSURL *url = [NSURL URLWithString:key];
    if (url) {
        [self storeData:data forKey:url.path extension:url.pathExtension done:doneBlock];
    }
    else {
        [self storeData:data forKey:key extension:nil done:doneBlock];
    }
}

- (NSString *)storeData:(NSData *)data forKey:(NSString *)key MIMEType:(NSString *)MIMEType error:(NSError *__autoreleasing *)error{
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(MIMEType), NULL);
    NSString *extension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension));
    return [self storeData:data forFileName:[self storeFileNameForKey:key extension:extension] error:error];
}

- (void)storeData:(NSData *)data forKey:(NSString *)key MIMEType:(NSString *)MIMEType done:(FileStoreSaveDataToDiskHandler)doneBlock {
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(MIMEType), NULL);
    NSString *extension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension));
    [self storeData:data forKey:key extension:extension done:doneBlock];
}

- (void)storeData:(NSData *)data forKey:(NSString *)key extension:(NSString *)extension done:(FileStoreSaveDataToDiskHandler)doneBlock {
    [self storeData:data forFileName:[self storeFileNameForKey:key extension:extension] done:doneBlock];
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

- (NSString *)storeData:(NSData *)data forFileName:(NSString *)fileName error:(NSError *__autoreleasing *)error {
    if (data && fileName) {
        
        if (![_fileManager fileExistsAtPath:_diskCachePath]) {
            [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:error];
        }
        
        if (!error && ![_fileManager createFileAtPath:[self.diskCachePath stringByAppendingPathComponent:fileName]
                                             contents:data
                                           attributes:nil]) {
            
            NSString * errorDescription = [NSString stringWithFormat:@"%s", strerror(errno)];
            (*error) = [NSError errorWithDomain:FileStoreErrorDomain
                                           code:errno
                                       userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
        }
        return error ? nil : fileName;
    }
    return nil;
}

- (NSString*)storeFileFromFileURL:(NSURL *)fileUrl forFileName:(NSString *)fileName error:(NSError**)error {
    NSString * key = [self storeFileNameForKey:fileName extension:fileUrl.pathExtension];
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

- (BOOL)storeFileFromURL:(NSURL*)filePath to:(NSURL *)destinationPath error:(NSError**)error {
    NSError * rootError = [NSError errorWithDomain:FileStoreErrorDomain
                                              code:0
                                          userInfo:@{ NSLocalizedDescriptionKey: @"Move data failed" }];
    
    if (![_fileManager fileExistsAtPath:[destinationPath.path stringByDeletingLastPathComponent]]) {
        if(![_fileManager createDirectoryAtURL:destinationPath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:error]) {
            *error = [rootError errorWithUnderlyingError:*error];
            return NO;
        }
    }
    
    [_fileManager removeItemAtURL:destinationPath error:nil];
    
    if (![_fileManager moveItemAtURL:filePath toURL:destinationPath error:error]) {
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

- (void)queryDiskDataForKey:(NSString *)key done:(FileStoreQueryDiskDataHandler)doneBlock {
    NSURL *url = [NSURL URLWithString:key];
    if (url) {
        [self queryDiskDataForKey:url.path extension:url.pathExtension done:doneBlock];
    }
    else {
        [self queryDiskDataForKey:key extension:nil done:doneBlock];
    }
}

- (void)queryDiskDataForKey:(NSString *)key MIMEType:(NSString *)MIMEType done:(FileStoreQueryDiskDataHandler)doneBlock {
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(MIMEType), NULL);
    NSString *extension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension));
    [self queryDiskDataForKey:key extension:extension done:doneBlock];
}

- (void)queryDiskDataForKey:(NSString *)key extension:(NSString *)extension done:(FileStoreQueryDiskDataHandler)doneBlock {
    [self queryDiskDataForFileName:[self storeFileNameForKey:key extension:extension] done:doneBlock];
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
    NSURL *url = [NSURL URLWithString:key];
    if (url) {
        return [self isDataStoredForKey:url.path extension:url.pathExtension];
    }
    else {
        return [self isDataStoredForKey:key extension:nil];
    }
}

- (BOOL)isDataStoredForKey:(NSString *)key MIMEType:(NSString *)MIMEType {
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(MIMEType), NULL);
    NSString *extension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension));
    return [self isDataStoredForKey:key extension:extension];
}

- (BOOL)isDataStoredForKey:(NSString *)key extension:(NSString *)extension {
    return [self isFileStoredNamed:[self storeFileNameForKey:key extension:extension]];
}

- (BOOL)isFileStoredNamed:(NSString*)fileName {
    NSString * filePath = [self.diskCachePath stringByAppendingPathComponent:fileName];
    return [_fileManager fileExistsAtPath:filePath];
}

- (NSURL *)filePathURLForKey:(NSString*)key {
    NSURL *url = [NSURL URLWithString:key];
    if (url) {
        return [self filePathURLForKey:url.path extension:url.pathExtension];
    }
    else {
        return [self filePathURLForKey:key extension:nil];
    }
}

- (NSURL *)filePathURLForKey:(NSString *)key MIMEType:(NSString *)MIMEType {
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(MIMEType), NULL);
    NSString *extension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension));
    return [self filePathURLForKey:key extension:extension];
}

- (NSURL *)filePathURLForKey:(NSString *)key extension:(NSString *)extension {
    return [self filePathURLForFileName:[self storeFileNameForKey:key extension:extension]];
}

- (NSURL *)filePathURLForFileName:(NSString *)filename {
    NSString * filePath = [self.diskCachePath stringByAppendingPathComponent:filename];
    if ([_fileManager fileExistsAtPath:filePath]) {
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}

- (void)removeDataForKey:(NSString *)key {
    NSURL *url = [NSURL URLWithString:key];
    if (url) {
        [self removeDataForKey:url.path extension:url.pathExtension];
    }
    else {
        [self removeDataForKey:key extension:nil];
    }
}

- (void)removeDataForKey:(NSString *)key MIMEType:(NSString *)MIMEType {
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef _Nonnull)(MIMEType), NULL);
    NSString *extension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension));
    return [self removeDataForKey:key extension:extension];
}

- (void)removeDataForKey:(NSString *)key extension:(NSString *)extension {
    [self removeDataForFileName:[self storeFileNameForKey:key extension:extension]];
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

- (NSString *)storeFileNameForKey:(NSString *)key extension:(NSString *)extension {
    if (key &&  key.length > 0) {
        const char *str = [key UTF8String];
        unsigned char r[CC_MD5_DIGEST_LENGTH];
        CC_MD5(str, (CC_LONG)strlen(str), r);
        NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                              r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
        if (extension && extension.length > 0) {
            filename = [filename stringByAppendingPathExtension:extension];
        }
        return filename;
    }
    return nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _ioQueue = nil;
}

@end
