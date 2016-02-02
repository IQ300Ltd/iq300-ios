//
//  DownloadManager.h
//  Tayphoon
//
//  Created by Tayphoon on 21.12.12.
//  Copyright (c) 2012 Tayphoon. All rights reserved.
//

#import <RestKit/RestKit.h>

@interface DownloadManager : NSObject

+ (DownloadManager *)sharedManager;

/**
 * Download data from url and store it. See FileStore.
 * @param url The file url address
 * @param success The success file download block
 * @param failure The failure file download block
 */
- (void)downloadDataFromURL:(NSString*)url
                    success:(void (^)(NSOperation *operation, NSURL * storedURL, NSData * responseData))success
                    failure:(void (^)(NSOperation *operation, NSError *error))failure;

- (void)downloadDataFromURL:(NSString *)url
                   MIMEType:(NSString *)MIMEType
                    success:(void (^)(NSOperation *operation, NSURL *storedURL, NSData *responseData))success
                    failure:(void (^)(NSOperation *operation, NSError *error))failure;

- (void)downloadDataFromURL:(NSString*)url
                    success:(void (^)(NSOperation *operation, NSURL * storedURL, NSData * responseData))success
                    failure:(void (^)(NSOperation *operation, NSError *error))failure
                andProgress:(void(^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress;

- (void)downloadDataFromURL:(NSString*)url
                   MIMEType:(NSString *)MIMEType
                    success:(void (^)(NSOperation *operation, NSURL * storedURL, NSData * responseData))success
                    failure:(void (^)(NSOperation *operation, NSError *error))failure
                andProgress:(void(^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress;


- (BOOL)isDataDownloadedFromURL:(NSString*)url;

- (NSURL*)storedFileUrlFromURL:(NSString*)url;
- (void)removeDataFromUrl:(NSString *)url;

- (void)cancelDownloadDataFromUrlString:(NSString *)url;
- (void)cancelDownloadDataFromUrl:(NSURL *)url;

@end
