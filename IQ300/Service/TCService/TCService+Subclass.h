//
//  TCService+Subclass.h
//  TCService
//
//  Created by Tayphoon on 13.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "TCService.h"

@class RKObjectRequestOperation;

@interface TCService(Subclass)

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 handler:(ObjectLoaderCompletionHandler)handler;

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
            fetchRequest:(NSFetchRequest*)fetchRequest
                 handler:(ObjectLoaderCompletionHandler)handler;

- (void)deleteObject:(id)object
                path:(NSString *)path
          parameters:(NSDictionary *)parameters
             handler:(ObjectLoaderCompletionHandler)handler;

- (void)putObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
          handler:(ObjectLoaderCompletionHandler)handler;

- (void)postObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
           handler:(ObjectLoaderCompletionHandler)handler;

- (void)postObjects:(NSArray*)objects path:(NSString *)path handler:(ObjectLoaderCompletionHandler)handler;

- (void)postData:(NSData*)data path:(NSString *)path handler:(ObjectLoaderCompletionHandler)handler;

- (void)postData:(NSData*)fileData path:(NSString *)path parameters:(NSDictionary *)parameters fileAttributeName:(NSString*)fileAttributeName
        fileName:(NSString*)fileName
        mimeType:(NSString*)mimeType
         handler:(ObjectLoaderCompletionHandler)handler;

- (void)initDescriptors;

- (void)processAuthorizationForOperation:(RKObjectRequestOperation*)operation;

- (void)processErrorResponse:(id<TCResponse>)response
                     handler:(ObjectLoaderCompletionHandler)handler;

- (void)processError:(NSError*)error
            response:(id<TCResponse>)response
        forOperation:(RKObjectRequestOperation*)operation
             handler:(ObjectLoaderCompletionHandler)handler;

- (NSError*)makeErrorWithDescription:(NSString*)errorDescription code:(NSInteger)code;

@end
