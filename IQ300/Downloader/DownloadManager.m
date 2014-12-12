//
//  DownloadManager.m
//  Tayphoon
//
//  Created by Tayphoon on 21.12.12.
//  Copyright (c) 2012 Tayphoon. All rights reserved.
//
#import "DownloadManager.h"
#import "FileStore.h"

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
                    success:(void (^)(NSOperation *operation, NSString * storedURL, NSData * responseData))success
                    failure:(void (^)(NSOperation *operation, NSError *error))failure {
    
    [self downloadDataFromURL:url
                      success:success
                      failure:failure
                  andProgress:nil];
}


- (void)downloadDataFromURL:(NSString*)url
                    success:(void (^)(NSOperation *operation, NSString * storedURL, NSData * responseData))success
                    failure:(void (^)(NSOperation *operation, NSError *error))failure
                andProgress:(void(^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress {
    NSString * escapedUrl = [url stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
    [[FileStore sharedStore] queryDiskDataForKey:escapedUrl done:^(NSData *data) {
        if(data) {
            if(success) {
                success(nil, [[FileStore sharedStore] storeFilePathForURL:url], data);
            }
        }
        else {
            
            void(^successBlock)(NSOperation *operation, NSData *responseData) = ^(NSOperation *operation, NSData *responseData) {
                [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                if(responseData) {
                    [[FileStore sharedStore] storeData:responseData
                                                forKey:url
                                                  done:^(NSString *fileName, NSError *error) {
                                                      if (!error && fileName)
                                                      {
                                                          success(operation, [[FileStore sharedStore] storeFilePathForURL:url], responseData);
                                                      }
                                                  }];
                }

            };
            
            void(^failureBlock)(NSOperation *operation, NSError *error) = ^(NSOperation *operation, NSError *error) {
                [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                if(failure) {
                    failure(operation, error);
                }
            };
            
            NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:escapedUrl]];
            AFHTTPRequestOperation * operation = [self downloadOperationWithRequest:request
                                                                            success:successBlock
                                                                            failure:failureBlock
                                                                        andProgress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                                                                                if (progress) {
                                                                                     progress(bytesRead, totalBytesRead, totalBytesExpectedToRead);
                                                                                }
                                                                            }];
            [self enqueueObjectRequestOperation:operation];
            [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
        }
    }];
}

- (void)authorizedDownloadDataFromURL:(NSString *)url
                              headers:(NSDictionary*)headers
                              success:(void (^)(NSOperation *, NSData *))success
                              failure:(void (^)(NSOperation *, NSError *))failure {
    [self authorizedDownloadDataFromURL:url
                                headers:headers
                                success:success
                                failure:failure
                            andProgress:nil];
}

- (void)authorizedDownloadDataFromURL:(NSString*)url
                              headers:(NSDictionary*)headers
                              success:(void (^)(NSOperation *operation, NSData * responseData))success
                              failure:(void (^)(NSOperation *operation, NSError *error))failure
                          andProgress:(void(^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress {
    [[FileStore sharedStore] queryDiskDataForKey:url done:^(NSData *data) {
        if(data) {
            if(success) {
                success(nil, data);
            }
        }
        else {
            NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            [request setAllHTTPHeaderFields:headers];
            
            AFHTTPRequestOperation * operation = [self downloadOperationWithRequest:request
                                                                            success:^(NSOperation *operation, NSData *responseData) {
                                                                                [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                                                                                if(responseData) {
                                                                                    [[FileStore sharedStore] storeData:responseData
                                                                                                                forKey:url
                                                                                                                  done:^(NSString *filePath, NSError *error) {
                                                                                                                      if (!error && filePath) {
                                                                                                                          if(success) {
                                                                                                                              success(operation, data);
                                                                                                                          }
                                                                                                                      }
                                                                                                                  }];
                                                                                }
                                                                            }
                                                                            failure:^(NSOperation *operation, NSError *error) {
                                                                                [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
                                                                                if(failure) {
                                                                                    failure(operation, error);
                                                                                }
                                                                            } andProgress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                                                                                if (progress) {
                                                                                    progress(bytesRead, totalBytesRead, totalBytesExpectedToRead);
                                                                                }
                                                                            }];
            [self enqueueObjectRequestOperation:operation];
            [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
        }
    }];
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
