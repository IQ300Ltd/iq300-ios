//
//  BackgroundDownloadManager.h
//  Tayphoon
//
//  Created by Tayphoon on 2/27/14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface BackgroundDownloadManager : NSObject

@property (nonatomic, strong) NSString * serverURL;
@property (nonatomic, strong) NSString * userName;
@property (nonatomic, strong) NSString * password;

+ (BackgroundDownloadManager*)sharedManager;

- (void)downloadDataFromURL:(NSString*)url
                    success:(void (^)(NSData * responseData))success
                    failure:(void (^)(NSError *error))failure
                andProgress:(void(^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress;

- (void)downloadDataFromURL:(NSString*)url
                 storeAtURL:(NSString*)destinationURL
                    success:(void (^)(NSData * responseData))success
                    failure:(void (^)(NSError *error))failure
                andProgress:(void(^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress;

- (void)setBackgroundFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

- (void)addCompletionHandler:(void (^)(void))completionHandler forSessionIdentifier:(NSString *)identifier;

- (void)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks;

- (void)callFetchCompletionHandler;

- (void)callFetchCompletionWithResult:(UIBackgroundFetchResult)fetchResult;

@end
 