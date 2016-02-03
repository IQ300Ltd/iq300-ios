//
//  DownloadManager.m
//  Tayphoon
//
//  Created by Tayphoon on 21.12.12.
//  Copyright (c) 2012 Tayphoon. All rights reserved.
//
#import "DownloadManager.h"
#import "FileStore.h"

@interface DownloadManager ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

static DownloadManager * _sharedManager = nil;

@implementation DownloadManager

+ (DownloadManager*)sharedManager {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    self = [super init];
    if(self) {
        self.operationQueue = [NSOperationQueue new];
        [self.operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    }
    return self;
}

#pragma mark - Public

- (AFHTTPRequestOperation*)downloadOperationWithRequest:(NSURLRequest *)request
                                                success:(void (^)(AFHTTPRequestOperation *operation, NSData * responseData))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:success
                                     failure:failure];
    return operation;
}


- (AFHTTPRequestOperation*)downloadOperationWithRequest:(NSURLRequest *)request
                                                success:(void (^)(AFHTTPRequestOperation *operation, NSData * responseData))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
                                            andProgress:(void(^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress {
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:success
                                     failure:failure];
    [operation setDownloadProgressBlock: progress];
    return operation;
}


- (void)downloadDataFromURL:(NSString*)url
                    success:(void (^)(NSOperation *operation, NSURL * storedURL, NSData * responseData))success
                    failure:(void (^)(NSOperation *operation, NSError *error))failure {
    
    [self downloadDataFromURL:url
                      success:success
                      failure:failure
                  andProgress:nil];
}

- (void)downloadDataFromURL:(NSString *)url
                   MIMEType:(NSString *)MIMEType
                    success:(void (^)(NSOperation *, NSURL *, NSData *))success
                    failure:(void (^)(NSOperation *, NSError *))failure {
    [self downloadDataFromURL:url
                     MIMEType:MIMEType
                      success:success
                      failure:failure
                  andProgress:nil];
}

- (void)downloadDataFromURL:(NSString*)url
                    success:(void (^)(NSOperation *operation, NSURL * storedURL, NSData * responseData))success
                    failure:(void (^)(NSOperation *operation, NSError *error))failure
                andProgress:(void(^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress {
    [self downloadDataFromURL:url
                     MIMEType:nil
                      success:success
                      failure:failure
                  andProgress:progress];

}

- (void)downloadDataFromURL:(NSString*)url
                   MIMEType:(NSString *)MIMEType
                    success:(void (^)(NSOperation *operation, NSURL * storedURL, NSData * responseData))success
                    failure:(void (^)(NSOperation *operation, NSError *error))failure
                andProgress:(void(^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress {
    
    NSURL *fromURL = [NSURL URLWithString:url];
    BOOL hasFileExtension = (fromURL && fromURL.pathExtension && fromURL.pathExtension.length > 0) || !MIMEType;
    
    void(^queryBlock)(NSData *data) = ^(NSData *data) {
        if (data) {
            if (success) {
                NSURL *filePath = nil;
                if (hasFileExtension) {
                    filePath =[[FileStore sharedStore] filePathURLForKey:fromURL.path extension:fromURL.pathExtension];
                }
                else if (MIMEType){
                    filePath = [[FileStore sharedStore] filePathURLForKey:fromURL.path MIMEType:MIMEType];
                }
                success(nil, filePath, data);
            }
        }
        else {
            
            void(^successBlock)(NSOperation *operation, NSData *responseData) = ^(NSOperation *operation, NSData *responseData) {
                [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                if(responseData) {
                    if (hasFileExtension) {
                        [[FileStore sharedStore] storeData:responseData
                                                    forKey:fromURL.path
                                                 extension:fromURL.pathExtension
                                                      done:^(NSString *fileName, NSError *error) {
                                                          if (!error && fileName)
                                                          {
                                                              success(operation, [[FileStore sharedStore] filePathURLForFileName:fileName], responseData);
                                                          }
                                                      }];
                    }
                    else {
                        [[FileStore sharedStore] storeData:responseData
                                                    forKey:fromURL.path
                                                  MIMEType:MIMEType
                                                      done:^(NSString *fileName, NSError *error) {
                                                          if (!error && fileName)
                                                          {
                                                              success(operation, [[FileStore sharedStore] filePathURLForFileName:fileName], responseData);
                                                          }
                                                      }];
                    }
                }
            };
            
            void(^failureBlock)(NSOperation *operation, NSError *error) = ^(NSOperation *operation, NSError *error) {
                [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                if(failure) {
                    failure(operation, error);
                }
            };
            
            void(^progressBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) = nil;
            if (progress) {
                progressBlock = ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                    progress(bytesRead, totalBytesRead, totalBytesExpectedToRead);
                };
            }
            
            NSString * escapedUrl = [url stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
            NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:escapedUrl]];
            AFHTTPRequestOperation * operation = [self downloadOperationWithRequest:request
                                                                            success:successBlock
                                                                            failure:failureBlock
                                                                        andProgress:progressBlock];
            [self enqueueObjectRequestOperation:operation];
            [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
        }
    };
    
    if (hasFileExtension) {
        [[FileStore sharedStore] queryDiskDataForKey:fromURL.path extension:fromURL.pathExtension done:queryBlock];
    }
    else {
        [[FileStore sharedStore] queryDiskDataForKey:fromURL.path MIMEType:MIMEType done:queryBlock];
    }
}

- (BOOL)isDataDownloadedFromURL:(NSString*)url {
    return [[FileStore sharedStore] isDataStoredForKey:url];
}

- (NSURL*)storedFileUrlFromURL:(NSString*)url {
    return [[FileStore sharedStore] filePathURLForKey:url];
}

- (void)removeDataFromUrl:(NSString *)url {    
    [[FileStore sharedStore] removeDataForKey:url];
}

- (void)cancelDownloadDataFromUrlString:(NSString *)url {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF.request.URL.absoluteString LIKE %@", url];
    NSArray * equalOperations = [self.operationQueue.operations filteredArrayUsingPredicate:predicate];
    if (equalOperations) {
        [equalOperations makeObjectsPerformSelector:@selector(cancel)];
    }
}

- (void)cancelDownloadDataFromUrl:(NSURL *)url {
    [self cancelDownloadDataFromUrlString:url.absoluteString];
}

#pragma mark - Queue Management

- (void)enqueueObjectRequestOperation:(AFHTTPRequestOperation *)objectRequestOperation {
    [self.operationQueue addOperation:objectRequestOperation];
}

@end
