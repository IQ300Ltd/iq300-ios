//
//  BackgroundDownloadManager.m
//  Tayphoon
//
//  Created by Tayphoon on 2/27/14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "BackgroundDownloadManager.h"
#import "DownloadTaskDelegate.h"
#import "FileStore.h"
#import "NSError+Extension.h"

static NSString * OBIBackgroundSessionIdenttificator = @"com.tayphoon.BackgroundSession";

NSString * const OBIBackgroundDownloadManagerErrorDomain = @"com.tayphoon.BackgroundDownloadManager.error";

static BackgroundDownloadManager * _sharedManager = nil;

static NSURLSession * _backgroundSession = nil;

typedef void (^BackgroundFetchCompleteHandler)(UIBackgroundFetchResult);

static dispatch_queue_t url_session_manager_creation_queue() {
    static dispatch_queue_t t_url_session_manager_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        t_url_session_manager_creation_queue = dispatch_queue_create("com.tayphoon.BackgroundDownloadManager.creation", DISPATCH_QUEUE_SERIAL);
    });
    
    return t_url_session_manager_creation_queue;
}

@interface BackgroundDownloadManager () <NSURLSessionDelegate, NSURLSessionDownloadDelegate> {
    BackgroundFetchCompleteHandler _completionHandler;
    NSMutableDictionary * _taskList;
    NSMutableDictionary * _completedTask;
    NSMutableDictionary * _sessionCompletionHandlers;
    NSOperationQueue * _taskQueue;
    NSTimer * _watchDogTimer;
}

@end

@implementation BackgroundDownloadManager

+ (BackgroundDownloadManager*)sharedManager {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
        _taskList = [NSMutableDictionary new];
        _completedTask = [NSMutableDictionary new];
        _taskQueue = [NSOperationQueue new];
        _taskQueue.maxConcurrentOperationCount = 1;
        _sessionCompletionHandlers = [NSMutableDictionary new];
        
        [self createCacheDirectoryIfNeed];
    }
    return self;
}

#pragma mark - Public methods

- (void)downloadDataFromURL:(NSString*)url
                    success:(void (^)(NSData * responseData))success
                    failure:(void (^)(NSError *error))failure
                andProgress:(void(^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress {
    NSString * destinationURL = [[FileStore sharedStore] storeFilePathForURL:url];
    [self downloadDataFromURL:url
                   storeAtURL:destinationURL
                      success:success
                      failure:failure
                  andProgress:progress];
}

- (void)downloadDataFromURL:(NSString*)url
                 storeAtURL:(NSString*)destinationURL
                    success:(void (^)(NSData * responseData))success
                    failure:(void (^)(NSError *error))failure
                andProgress:(void(^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress {
    
    NSString * escapedUrl = [url stringByReplacingOccurrencesOfString:@"'" withString:@"%27"];
    
    [[FileStore sharedStore] queryDiskDataForKey:escapedUrl done:^(NSData *data) {
        if(data) {
            if(success) {
                success(data);
            }
        }
        else {
            NSURL * downloadUrl = [NSURL URLWithString:escapedUrl];
           
            __block NSURLSessionDownloadTask *downloadTask = nil;
            dispatch_sync(url_session_manager_creation_queue(), ^{
                downloadTask = [self.backgroundSession downloadTaskWithURL:downloadUrl];
            });
            
            if (!downloadTask) {
                [self reinitUrlSession];
                
                dispatch_sync(url_session_manager_creation_queue(), ^{
                    downloadTask = [self.backgroundSession downloadTaskWithURL:downloadUrl];
                });
                
                if (!downloadTask) {
                    NSString * errorFormat = @"Failed create download task for session: %@, download task for url: '%@'";
                    NSString * errorDescription = [NSString stringWithFormat:errorFormat, self.backgroundSession, downloadUrl];
                    NSError * error = [self downloadError];
                    if (failure)  {
                        error = [error errorWithUnderlyingError:[NSError errorWithDomain:OBIBackgroundDownloadManagerErrorDomain
                                                                                    code:0
                                                                                userInfo:@{ NSLocalizedDescriptionKey: errorDescription}]];
                        failure(error);
                    }
                }
            }
            
            if (downloadTask) {
                DownloadTaskDelegate * delegate = [[DownloadTaskDelegate alloc] initWithTask:downloadTask successURL:^(NSURL *responseDataURL) {
                    if(responseDataURL) {
                        NSError * error = nil;
                        [[FileStore sharedStore] storeFileFromURL:responseDataURL
                                                           atPath:destinationURL
                                                            error:&error];
                        NSData * fileData = nil;
                        if (!error) {
                            fileData = [NSData dataWithContentsOfFile:destinationURL
                                                              options:NSDataReadingMappedAlways
                                                                error:&error];
                            if (!error && fileData)  {
                                success(fileData);
                            }
                        }
                        
                        if (error && failure)  {
                            NSError * downloadError = [self downloadError];
                            downloadError = [downloadError errorWithUnderlyingError:error];
                            failure(downloadError);
                        }
                    }
                } failure:^(NSError *error) {
                    if (failure) {
                        failure(error);
                    }
                } andProgress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                    if(progress) {
                        progress(bytesRead, totalBytesRead, totalBytesExpectedToRead);
                    }
                }];
                
                [_taskList setObject:delegate forKey:downloadTask];
                [downloadTask resume];
            }
        }
    }];
}

- (void)setBackgroundFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    _completionHandler = completionHandler;
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        if (_watchDogTimer) {
            [_watchDogTimer invalidate];
            _watchDogTimer = nil;
        }
        
        _watchDogTimer = [NSTimer scheduledTimerWithTimeInterval:[UIApplication sharedApplication].backgroundTimeRemaining - 1.0
                                                          target:self
                                                        selector:@selector(checkBackroundTime:)
                                                        userInfo:nil
                                                         repeats:NO];
    }
}

- (void)addCompletionHandler:(void (^)(void))completionHandler forSessionIdentifier:(NSString *)identifier {
    if ([_sessionCompletionHandlers objectForKey:identifier]) {
        NSLog(@"Error: Got multiple handlers for a single session identifier. This should not happen.");
    }
    [_sessionCompletionHandlers setObject:[completionHandler copy] forKey:identifier];
}

- (void)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (cancelPendingTasks) {
            [self.backgroundSession invalidateAndCancel];
        } else {
            [self.backgroundSession finishTasksAndInvalidate];
        }
    });
}

- (void)callFetchCompletionHandler {
    [self callFetchCompletionWithResult:_completedTask.count > 0 ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData];
}

- (void)callFetchCompletionWithResult:(UIBackgroundFetchResult)fetchResult {
    if (_completionHandler) {
        _completionHandler(fetchResult);
        _completionHandler = nil;
    }
}

#pragma mark - Watchdog timer

- (void)checkBackroundTime:(NSTimer *)timer {
    [_watchDogTimer invalidate];
    _watchDogTimer = nil;
    
    NSLog(@"background fetch interupted due timeout");
    [self callFetchCompletionHandler];
}

#pragma mark - Download delegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    DownloadTaskDelegate * taskDelegate = nil;
    taskDelegate = [self delegateForTask:downloadTask];
    if (taskDelegate) {
        [taskDelegate URLSession:session
                    downloadTask:downloadTask
               didResumeAtOffset:fileOffset
              expectedTotalBytes:expectedTotalBytes];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    DownloadTaskDelegate * taskDelegate = [self delegateForTask:downloadTask];
    
    if (taskDelegate) {
        [taskDelegate URLSession:session downloadTask:downloadTask didFinishDownloadingToURL:location];
        [_taskList removeObjectForKey:downloadTask];
        [_completedTask setObject:taskDelegate forKey:downloadTask];
        
        if (_taskList.count == 0) {
            BOOL hasNewData = ([_completedTask count] > 0);
            [_taskList removeAllObjects];
            [_completedTask removeAllObjects];
            [self callFetchCompletionWithResult:(hasNewData) ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData];
        }
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    DownloadTaskDelegate * taskDelegate = [self delegateForTask:downloadTask];
    
    if (taskDelegate) {
        [taskDelegate URLSession:session
                    downloadTask:downloadTask
                    didWriteData:bytesWritten
               totalBytesWritten:totalBytesWritten
       totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        NSLog(@"task error: %@", error.localizedDescription);
        NSLog(@"url %@", task.response.URL);

        DownloadTaskDelegate * taskDelegate = [self delegateForTask:task];
        
        if (taskDelegate) {
            [taskDelegate URLSession:(NSURLSession *)session task:task didCompleteWithError:error];
            [_completedTask setObject:taskDelegate forKey:task];
        }
        
        [_taskList removeObjectForKey:task];
    }
}

#pragma mark - NSURlSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    if(error) {
        NSLog(@"error in session: %@", error.localizedDescription);
    }
    [self reinitUrlSession];
}

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSURL * serviceUrl = [NSURL URLWithString:self.serverURL];
    NSURLCredential * credential = nil;
    if ([challenge.protectionSpace.host isEqualToString:serviceUrl.host]) {
        credential = [NSURLCredential credentialWithUser:self.userName
                                                password:self.password
                                             persistence:NSURLCredentialPersistenceForSession];
    }
    else {
       credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    }
    
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    if (session.configuration.identifier) {
        [self callCompletionHandlerForSession:session.configuration.identifier];
    }
}

#pragma mark - Private methods

- (DownloadTaskDelegate *)delegateForTask:(NSURLSessionTask*)task {
    DownloadTaskDelegate * taskDelegate = [_taskList objectForKey:task];
    return taskDelegate;
}

- (void)callCompletionHandlerForSession:(NSString *)sessionIdentifier {
    void (^compleationHandler)(void) = [_sessionCompletionHandlers objectForKey:sessionIdentifier];
    
    if (compleationHandler) {
        [_sessionCompletionHandlers removeObjectForKey:compleationHandler];
        compleationHandler();
    }
}

- (NSURLSession*)backgroundSession {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfiguration:OBIBackgroundSessionIdenttificator];
        _backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    });
    return _backgroundSession;
}

- (void)reinitUrlSession {
    if (_backgroundSession) {
        [_backgroundSession resetWithCompletionHandler:nil];
        _backgroundSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:OBIBackgroundSessionIdenttificator]
                                                           delegate:self
                                                      delegateQueue:_taskQueue];
        
    }
}

- (void)createCacheDirectoryIfNeed {
    NSArray  * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString * cacheDirectory = [paths objectAtIndex:0];
    NSError * err = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:[cacheDirectory stringByAppendingPathComponent:@"com.apple.nsnetworkd"]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&err];
    if (err) {
        NSLog(@"%s error: %@",__PRETTY_FUNCTION__, err.localizedDescription);
    }
}

- (NSError*)downloadError {
    NSError * downloadError = [NSError errorWithDomain:OBIBackgroundDownloadManagerErrorDomain
                                                  code:0
                                              userInfo:@{ NSLocalizedDescriptionKey: @"Download failed"}];
    return downloadError;
}

@end
