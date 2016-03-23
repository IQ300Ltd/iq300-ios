//
//  IQService.m
//  IQ300
//
//  Created by Tayphoon on 13.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>
#import <objc/runtime.h>

#import "IQService.h"
#import "IQServiceResponse.h"
#import "IQObjects.h"
#import "TCObjectSerializator.h"

static const void *RKObjectRequestOperationBlock = &RKObjectRequestOperationBlock;

@interface RKObjectRequestOperation(OperationBlock)

@property (nonatomic, copy) void (^operationBlock)(void);

@end

@implementation RKObjectRequestOperation(OperationBlock)

- (void)setOperationBlock:(void (^)(void))operationBlock {
    objc_setAssociatedObject(self, RKObjectRequestOperationBlock, operationBlock, OBJC_ASSOCIATION_COPY);
}

- (void(^)(void))operationBlock {
    return objc_getAssociatedObject(self, RKObjectRequestOperationBlock);
}

@end

@interface IQToken : NSObject

@property (nonatomic, strong) NSNumber * userId;
@property (nonatomic, strong) NSString * token;

+ (RKObjectMapping*)objectMapping;

@end

@implementation IQToken

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping* objectMapping = [RKObjectMapping mappingForClass:[IQToken class]];
    [objectMapping addAttributeMappingsFromDictionary:@{
                                                        @"access_token": @"token",
                                                        @"userId" : @"userId"
                                                        }];
    
    return objectMapping;
}

@end

NSDictionary * IQParametersExcludeEmpty(NSDictionary * parameters) {
    NSMutableDictionary * param = [NSMutableDictionary dictionaryWithDictionary:parameters];
    for (NSString * key in [parameters allKeys]) {
        id value = parameters[key];
        if(!value || [value isEqual:[NSNull null]]) {
            [param removeObjectForKey:key];
        }
    }
    return [param copy];
}

NSString * IQSortDirectionToString(IQSortDirection direction) {
    if(direction != IQSortDirectionNo) {
        return (direction == IQSortDirectionAscending) ? @"asc" : @"desc";
    }
    return nil;
}

BOOL IsNetworUnreachableError(NSError * error) {
    return error.code == kCFURLErrorNotConnectedToInternet ||
           error.code == kCFURLErrorNetworkConnectionLost;
}

@interface IQService() {
    dispatch_queue_t _extendTokenQueue;
    dispatch_group_t _extendTokenGroup;
    BOOL _isTokenExtended;
    BOOL _isTokenExtensionsFiled;
}

@end

@implementation IQService

@dynamic session;

- (id)initWithURL:(NSString *)url andSession:(id)session {
    self = [super initWithURL:url andSession:session];
    if (self) {
        self.responseClass = [IQServiceResponse class];
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

#pragma mark - Public methods

- (NSString*)storeFileName {
    return @"IQ300";
}

- (void)loginWithDeviceToken:(NSString*)deviceToken email:(NSString*)email password:(NSString*)password handler:(RequestCompletionHandler)handler {
    NSDictionary * parameters = @{ @"device_token" : NSStringNullForNil(deviceToken),
                                   @"email"        : NSStringNullForNil(email),
                                   @"password"     : NSStringNullForNil(password) };
    [self postObject:nil
                path:@"sessions"
          parameters:parameters
             handler:^(BOOL success, IQToken * token, NSData *responseData, NSError *error) {
                 if (success && token) {
                     self.session = [IQSession sessionWithEmail:nil andPassword:nil token:token.token];
                     self.session.userId = token.userId;
                 }
                 
                 if(handler) {
                     handler(success, responseData, error);
                 }
             }];
}

- (void)logout {
    if (self.session.token) {
        [self deleteObject:nil
                      path:@"sessions"
                parameters:@{ @"access_token" : self.session.token }
                   handler:nil];
        self.session = nil;
    }
}

- (void)signupWithFirstName:(NSString*)firstName
                   lastName:(NSString*)lastName
             communityTitle:(NSString*)communityTitle
                      email:(NSString*)email
                   password:(NSString*)password
                deviceToken:(NSString*)deviceToken
                    handler:(RequestCompletionHandler)handler {
    NSDictionary * parameters = @{ @"first_name"      : NSStringNullForNil(firstName),
                                   @"last_name"       : NSStringNullForNil(lastName),
                                   @"community_title" : NSStringNullForNil(communityTitle),
                                   @"email"           : NSStringNullForNil(email),
                                   @"password"        : NSStringNullForNil(password),
                                   @"device_token"    : NSStringNullForNil(deviceToken)
                                   };
    [self postObject:nil
                path:@"registrations"
          parameters:parameters
             handler:^(BOOL success, IQToken * token, NSData *responseData, NSError *error) {
                 if (success && token) {
                     self.session = [IQSession sessionWithEmail:nil andPassword:nil token:token.token];
                     self.session.userId = token.userId;
                 }

                 if(handler) {
                     handler(success, responseData, error);
                 }
             }];
}

- (void)confirmRegistrationWithToken:(NSString*)token deviceToken:(NSString*)deviceToken handler:(RequestCompletionHandler)handler {
    NSDictionary * parameters = @{ @"device_token"       : NSStringNullForNil(deviceToken),
                                   @"confirmation_token" : NSStringNullForNil(token)};
    [self postObject:nil
                path:@"confirmation"
          parameters:parameters
             handler:^(BOOL success, IQToken * token, NSData *responseData, NSError *error) {
                 if (success && token) {
                     self.session = [IQSession sessionWithEmail:nil andPassword:nil token:token.token];
                     self.session.userId = token.userId;
                 }
                 
                 if(handler) {
                     handler(success, responseData, error);
                 }
             }];

}

- (void)userInfoWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"users/current"
                parameters:nil
                   handler:^(BOOL success, IQUser * user, NSData *responseData, NSError *error) {
                       if(success) {
                           self.session.userId = user.userId;
                       }
                       if(handler) {
                           handler(success, user, responseData, error);
                       }
                   }];
}

- (void)registerDeviceForRemoteNotificationsWithToken:(NSString*)token handler:(RequestCompletionHandler)handler {
    if([token length] > 0) {
        NSDictionary * parameters = @{ @"device" :
                                           @{
                                               @"platform" : @"ios",
                                               @"token"    : token
                                            }
                                     };
        [self postObject:nil
                    path:@"devices"
              parameters:parameters
                 handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                     if(handler) {
                         handler(success, responseData, error);
                     }
                 }];
    }
}

#pragma mark - TCService override

- (void)getObjectsAtPath:(NSString *)path
              parameters:(NSDictionary *)parameters
              fetchBlock:(NSFetchRequest *(^)(NSURL *URL))fetchBlock
                 handler:(ObjectRequestCompletionHandler)handler {
    
    [super getObjectsAtPath:path parameters:parameters fetchBlock:fetchBlock handler:handler];
    RKObjectRequestOperation * operation = [self.objectManager.operationQueue.operations lastObject];
    
    void (^operationBlock)(void) = ^{
        [self getObjectsAtPath:path
                    parameters:parameters
                       handler:handler];
    };
    
    operation.operationBlock = operationBlock;
}

- (void)deleteObject:(id)object
                path:(NSString *)path
          parameters:(NSDictionary *)parameters
          fetchBlock:(NSFetchRequest *(^)(NSURL *URL))fetchBlock
             handler:(ObjectRequestCompletionHandler)handler {
    [super deleteObject:object
                   path:path
             parameters:parameters
             fetchBlock:fetchBlock
                handler:handler];
    
    RKObjectRequestOperation * operation = [self.objectManager.operationQueue.operations lastObject];
    
    void (^operationBlock)(void) = ^{
        [self deleteObject:object
                      path:path
                parameters:parameters
                fetchBlock:fetchBlock
                   handler:handler];
    };
    
    operation.operationBlock = operationBlock;
}

- (void)putObject:(id)object
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
       fetchBlock:(NSFetchRequest *(^)(NSURL *URL))fetchBlock
          handler:(ObjectRequestCompletionHandler)handler {
    [super putObject:object
                path:path
          parameters:parameters
          fetchBlock:fetchBlock
             handler:handler];
    
    RKObjectRequestOperation * operation = [self.objectManager.operationQueue.operations lastObject];
    
    void (^operationBlock)(void) = ^{
        [self putObject:object
                   path:path
             parameters:parameters
             fetchBlock:fetchBlock
                handler:handler];
    };
    
    operation.operationBlock = operationBlock;
}

- (void)postObject:(id)object
              path:(NSString *)path
        parameters:(NSDictionary *)parameters
        fetchBlock:(NSFetchRequest *(^)(NSURL *URL))fetchBlock
           handler:(ObjectRequestCompletionHandler)handler {
    [super postObject:object
                 path:path
           parameters:parameters
           fetchBlock:fetchBlock
              handler:handler];
    
    RKObjectRequestOperation * operation = [self.objectManager.operationQueue.operations lastObject];
    
    void (^operationBlock)(void) = ^{
        [self postObject:object
                    path:path
              parameters:parameters
              fetchBlock:fetchBlock
                 handler:handler];
    };
    
    operation.operationBlock = operationBlock;
}

- (void)postAsset:(ALAsset*)asset
             path:(NSString *)path
       parameters:(NSDictionary *)parameters
fileAttributeName:(NSString*)fileAttributeName
         fileName:(NSString*)fileName
         mimeType:(NSString*)mimeType
          handler:(ObjectRequestCompletionHandler)handler {
    [super postAsset:asset
                path:path
          parameters:parameters
   fileAttributeName:fileAttributeName
            fileName:fileName
            mimeType:mimeType
             handler:handler];
    
    RKObjectRequestOperation * operation = [self.objectManager.operationQueue.operations lastObject];
    
    void (^operationBlock)(void) = ^{
        [self postAsset:asset
                   path:path
             parameters:parameters
      fileAttributeName:fileAttributeName
               fileName:fileName
               mimeType:mimeType
                handler:handler];
    };
    
    operation.operationBlock = operationBlock;
}

- (void)postFileAtPath:(NSURL*)filePath
                  path:(NSString*)path
            parameters:(NSDictionary*)parameters
     fileAttributeName:(NSString*)fileAttributeName
              fileName:(NSString*)fileName
              mimeType:(NSString*)mimeType
               handler:(ObjectRequestCompletionHandler)handler {
    [super postFileAtPath:filePath
                     path:path
               parameters:parameters
        fileAttributeName:fileAttributeName
                 fileName:fileName
                 mimeType:mimeType
                  handler:handler];
    
    RKObjectRequestOperation * operation = [self.objectManager.operationQueue.operations lastObject];
    
    void (^operationBlock)(void) = ^{
        [self postFileAtPath:filePath
                        path:path
                  parameters:parameters
           fileAttributeName:fileAttributeName
                    fileName:fileName
                    mimeType:mimeType
                     handler:handler];
    };
    
    operation.operationBlock = operationBlock;
}


#pragma mark - Attachments methods

- (void)createAttachmentWithAsset:(ALAsset*)asset fileName:(NSString*)fileName mimeType:(NSString *)mimeType handler:(ObjectRequestCompletionHandler)handler {
    [self postAsset:asset
               path:@"attachments"
         parameters:nil
  fileAttributeName:@"attachment[file]"
           fileName:fileName
           mimeType:mimeType
            handler:handler];
}

- (void)createAttachmentWithFileAtPath:(NSString*)filePath fileName:(NSString*)fileName mimeType:(NSString *)mimeType handler:(ObjectRequestCompletionHandler)handler {
    [self postFileAtPath:[NSURL fileURLWithPath:filePath isDirectory:NO]
                    path:@"attachments"
              parameters:nil
       fileAttributeName:@"attachment[file]"
                fileName:fileName
                mimeType:mimeType
                 handler:handler];
}

- (void)createAttachmentWithImage:(UIImage*)image fileName:(NSString*)fileName mimeType:(NSString *)mimeType handler:(ObjectRequestCompletionHandler)handler {
    [self postData:UIImagePNGRepresentation(image)
              path:@"attachments"
        parameters:nil
 fileAttributeName:@"attachment[file]"
          fileName:fileName
          mimeType:mimeType
           handler:handler];
}

#pragma mark - Token Extend methods

- (dispatch_queue_t)dispatchQueue {
    if(!_extendTokenQueue) {
        _extendTokenQueue = dispatch_queue_create("com.iq300.token-extend-queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return _extendTokenQueue;
}

- (dispatch_group_t)dispatchGroup {
    if(!_extendTokenGroup) {
        _extendTokenGroup = dispatch_group_create();
    }
    
    return _extendTokenGroup;
}

- (void)extendAccessToken:(ObjectRequestCompletionHandler)handler operationBlock:(void (^)(void))operationBlock {
    
    dispatch_group_async([self dispatchGroup], [self dispatchQueue], ^{
        if(!_isTokenExtensionsFiled) {
            if(!_isTokenExtended) {
                IQLogDebug(@"Try extend token");

                [self syncLoginWithDeviceToken:self.session.deviceToken
                                         email:self.session.email
                                      password:self.session.password
                                       handler:^(BOOL success, IQToken * token, NSData *responseData, NSError *error) {
                                           if(success) {
                                               IQLogDebug(@"Extend token success");
                                               IQSession * session = [IQSession sessionWithEmail:self.session.email
                                                                                     andPassword:self.session.password
                                                                                           token:token.token];
                                               session.deviceToken = self.session.deviceToken;
                                               session.userId = token.userId;
                                               self.session = session;
                                               
                                               [IQSession setDefaultSession:self.session];
                                               
                                               _isTokenExtended = YES;
                                               _isTokenExtensionsFiled = NO;

                                               if(operationBlock) {
                                                   operationBlock();
                                               }
                                           }
                                           else {
                                               NSError * loginError = [self makeErrorWithDescription:@"Authorization failed" code:401];
                                               IQLogError(@"%@", error);
                                               _isTokenExtended = NO;
                                               _isTokenExtensionsFiled = YES;
                                               if (handler) {
                                                   handler(NO, nil, nil, loginError);
                                               }
                                           }
                                       }];
                
                [self waitTokenExtendGroupWithCompletionBlock:^{
                    _isTokenExtended = NO;
                    _isTokenExtensionsFiled = NO;
                }];
            }
            else if(operationBlock) {
                operationBlock();
            }
        }
    });
}

- (void)waitTokenExtendGroupWithCompletionBlock:(void (^)(void))completion {
    if (completion) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            dispatch_group_wait([self dispatchGroup], DISPATCH_TIME_FOREVER);
            completion();
        });
    }
}

#pragma mark - Private methods

- (void)syncLoginWithDeviceToken:(NSString*)deviceToken email:(NSString*)email password:(NSString*)password handler:(ObjectRequestCompletionHandler)handler {
    if(handler) {
        NSDictionary * parameters = @{ @"device_token" : NSStringNullForNil(deviceToken),
                                       @"email"        : NSStringNullForNil(email),
                                       @"password"     : NSStringNullForNil(password) };
        
        NSURLRequest * loginRequest = [self.objectManager requestWithObject:nil
                                                                     method:RKRequestMethodPOST
                                                                       path:@"sessions"
                                                                 parameters:parameters];
        NSURLResponse *response = nil;
        NSError * responseError = nil;
        NSData * responseData = [NSURLConnection sendSynchronousRequest:loginRequest returningResponse:&response error:&responseError];
        NSInteger responseStatusCode = [(NSHTTPURLResponse *)response statusCode];
        if (responseError) {
            handler(NO, nil, responseData, responseError);
        }
        else {
            if (responseStatusCode != 200) {
                NSString * errorDescription = [NSString stringWithFormat:@"Failed with response status code %ld", (long)responseStatusCode];
                NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : errorDescription };
                NSError * error = [NSError errorWithDomain:TCServiceErrorDomain
                                                      code:responseStatusCode
                                                  userInfo:userInfo];
                handler(NO, nil, responseData, error);
            }
            else {
                NSError * serializationError = nil;
                NSString * responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                NSDictionary * serviceResponse = [TCObjectSerializator JSONDictionaryWithString:responseString error:&serializationError];
                if (!serializationError && serviceResponse) {
                    NSDictionary * tokenData = @{ @"IQToken" : serviceResponse };
                    IQToken * token = [TCObjectSerializator objectFromDictionary:tokenData
                                                            destinationClass:[IQToken class]
                                                                       error:&serializationError];
                    handler((token != nil), token, responseData, serializationError);
                }
                else  {
                    NSError * loginError = [self makeErrorWithDescription:[serviceResponse objectForKey:@"ErrorMessage"] code:401];
                    handler(NO, nil, responseData, loginError);
                }
            }
        }
    }
}

- (void)processError:(NSError*)error
            response:(id<TCResponse>)response
        forOperation:(RKObjectRequestOperation*)operation
             handler:(ObjectRequestCompletionHandler)handler {
    
    if (operation.HTTPRequestOperation.response.statusCode == 401 &&
        self.session.email && self.session.password) {
        [self extendAccessToken:handler operationBlock:operation.operationBlock];
    }
    else if(handler) {
        handler(NO, nil, operation.HTTPRequestOperation.responseData, error);
    }
}

- (void)processAuthorizationForOperation:(RKObjectRequestOperation *)operation {
    if(self.session) {
        NSString * token = [NSString stringWithFormat:@"%@ %@", self.session.tokenType, self.session.token];
        [((NSMutableURLRequest*)operation.HTTPRequestOperation.request) addValue:token forHTTPHeaderField:@"Authorization"];
    }
}

- (void)initDescriptors {
    RKResponseDescriptor * descriptor = [IQServiceResponse responseDescriptorForClass:[IQToken class]
                                                                               method:RKRequestMethodPOST
                                                                          pathPattern:@"sessions"
                                                                          fromKeyPath:nil
                                                                                store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodDELETE
                                                         pathPattern:@"sessions"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQToken class]
                                                                               method:RKRequestMethodPOST
                                                                          pathPattern:@"registrations"
                                                                          fromKeyPath:nil
                                                                                store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQToken class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"confirmation"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQNotificationsHolder class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"notifications"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQNotificationIds class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"notifications/unread_ids"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQUser class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"users/current"
                                                   fromKeyPath:@"user"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"notifications/read"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"notifications/read_all"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQNotificationCounters class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"notifications/counters"
                                                   fromKeyPath:@"notification_counters"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQConversation class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"conversations"
                                                   fromKeyPath:@"conversations"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQConversation class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"conversations/:id"
                                                   fromKeyPath:@"conversation"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQConversation class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"conversations"
                                                   fromKeyPath:@"conversation"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQConversation class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"conversations/create_conference"
                                                   fromKeyPath:@"conversation"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQConversation class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"conversations/:id/dialog_to_conference"
                                                   fromKeyPath:@"conversation"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQConversationMember class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"conversations/:id/participants"
                                                   fromKeyPath:@"participants"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[ConversationDeletedObjects class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"conversations/deleted_ids"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:@"conversations/:id/participants"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodDELETE
                                                         pathPattern:@"conversations/:id/participants/:id"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"conversations/:id/participants/leave"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"conversations/:id/update_title"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"discussions/:id"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"discussions/:id/comments/read"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQDiscussion class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"discussions/:id"
                                                   fromKeyPath:@"discussion"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQCounters class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"conversations/counters"
                                                   fromKeyPath:@"conversation_counters"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQComment class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"discussions/:id/comments"
                                                   fromKeyPath:@"comments"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQComment class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"discussions/:id/comments"
                                                   fromKeyPath:@"comment"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQComment class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"discussions/:id/comments/:id"
                                                   fromKeyPath:@"comment"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQManagedAttachment class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"attachments"
                                                   fromKeyPath:@"attachment"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQContact class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"contacts"
                                                   fromKeyPath:@"contacts"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQContactsDeletedIds class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"contacts/deleted_ids"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:@"devices"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"notifications/:id/accept"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"notifications/:id/decline"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"notifications/:id/pin"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"notifications/:id/unpin"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];
    
    //Tasks
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQTasksHolder class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[TaskFilterCounters class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/filter_counters"
                                                   fromKeyPath:@"filter_counters"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[TasksMenuCounters class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/menu_counters"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[TChangesCounter class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/:id/changes"
                                                   fromKeyPath:@"changes"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQTask class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/:id/"
                                                   fromKeyPath:@"task"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQTask class]
                                                        method:RKRequestMethodPUT
                                                   pathPattern:@"tasks/:id/change_status"
                                                   fromKeyPath:@"task"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQTask class]
                                                        method:RKRequestMethodPUT
                                                   pathPattern:@"tasks/:id/rollback"
                                                   fromKeyPath:@"task"
                                                         store:self.objectManager.managedObjectStore];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQManagedTodoItem class]
                                                        method:RKRequestMethodPUT
                                                   pathPattern:@"tasks/:id/todo_items/:id/complete"
                                                   fromKeyPath:@"todo_item"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQManagedTodoItem class]
                                                        method:RKRequestMethodPUT
                                                   pathPattern:@"tasks/:id/todo_items/:id/rollback"
                                                   fromKeyPath:@"todo_item"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQManagedTodoItem class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/:id/todo_items"
                                                   fromKeyPath:@"todo_items"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    RKMapping * mapping = [TCRequestItemsHolder requestObjectMappingForClass:[IQTodoItem class]
                                                                   toKeyPath:@"todo_items"
                                                                       store:self.objectManager.managedObjectStore];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:mapping
                                                                                   objectClass:[TCRequestItemsHolder class]
                                                                                   rootKeyPath:nil
                                                                                        method:RKRequestMethodPOST];
    [self.objectManager addRequestDescriptor:requestDescriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQManagedTodoItem class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"tasks/:id/todo_items/apply_changes"
                                                   fromKeyPath:@"todo_items"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"tasks/:id/changes/read"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];;
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQTaskMember class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/:id/accessor_users"
                                                   fromKeyPath:@"accessor_users"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQTaskMember class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"tasks/:id/accessor_users"
                                                   fromKeyPath:@"accessor_user"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodDELETE
                                                         pathPattern:@"tasks/:id/accessor_users/:id"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQManagedAttachment class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/:id/attachments"
                                                   fromKeyPath:@"attachments"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQManagedAttachment class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"tasks/:id/attachments"
                                                   fromKeyPath:@"attachment"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"tasks/:id/accessor_users/leave"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];;
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[TaskPolicies class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/:id/abilities"
                                                   fromKeyPath:@"policy"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQTaskActivityItem class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/:id/activities"
                                                   fromKeyPath:@"activities"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQCommunity class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/communities"
                                                   fromKeyPath:@"communities"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQCommunity class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/communities/most_used"
                                                   fromKeyPath:@"community"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[TaskExecutorsGroup class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"communities/:id/executors"
                                                   fromKeyPath:@"executors"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[IQTaskDataHolder createRequestObjectMapping]
                                                              objectClass:[IQTaskDataHolder class]
                                                              rootKeyPath:@"task"
                                                                   method:RKRequestMethodPOST];
    [self.objectManager addRequestDescriptor:requestDescriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQTask class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"tasks"
                                                   fromKeyPath:@"task"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[IQTaskDataHolder editRequestObjectMapping]
                                                              objectClass:[IQTaskDataHolder class]
                                                              rootKeyPath:@"task"
                                                                   method:RKRequestMethodPUT];
    [self.objectManager addRequestDescriptor:requestDescriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQTask class]
                                                        method:RKRequestMethodPUT
                                                   pathPattern:@"tasks/:id/"
                                                   fromKeyPath:@"task"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQTask class]
                                                        method:RKRequestMethodPUT
                                                   pathPattern:@"tasks/:id/reconciliation_list/approve"
                                                   fromKeyPath:@"task"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQTask class]
                                                        method:RKRequestMethodPUT
                                                   pathPattern:@"tasks/:id/reconciliation_list/disapprove"
                                                   fromKeyPath:@"task"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQTaskDeletedIds class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/deleted_ids"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[CommentDeletedObjects class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"discussions/:id/comments/deleted_ids"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodDELETE
                                                         pathPattern:@"discussions/:id/comments/:id"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];;
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQFeedbacksHolder class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"error_reports"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQManagedFeedback class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"error_reports/:id"
                                                   fromKeyPath:@"error_report"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQManagedFeedback class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"error_reports"
                                                   fromKeyPath:@"error_report"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[IQFeedback requestObjectMapping]
                                                              objectClass:[IQFeedback class]
                                                              rootKeyPath:@"error_report"
                                                                   method:RKRequestMethodPOST];
    [self.objectManager addRequestDescriptor:requestDescriptor];

    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQFeedbackCategory class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"error_reports/categories"
                                                   fromKeyPath:@"error_report_categories"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQFeedbackType class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"error_reports/types"
                                                   fromKeyPath:@"error_report_types"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQComplexity class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/complexity_kinds"
                                                   fromKeyPath:@"data"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQSubtasksHolder class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"tasks/:id/children"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
}

@end
