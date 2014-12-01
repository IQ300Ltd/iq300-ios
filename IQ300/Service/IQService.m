//
//  IQService.m
//  IQ300
//
//  Created by Tayphoon on 13.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQService.h"
#import "IQServiceResponse.h"
#import "IQObjects.h"

#define NSStringEmptyForNil(value) ([value length]) ? value : [NSNull null]
#define NSObjectEmptyForNil(value) (value) ? value : [NSNull null]

@interface IQToken : NSObject

@property (nonatomic, strong) NSString * token;

+ (RKObjectMapping*)objectMapping;

@end

@implementation IQToken

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping* objectMapping = [RKObjectMapping mappingForClass:[IQToken class]];
    [objectMapping addAttributeMappingsFromDictionary:@{
                                                        @"access_token": @"token",
                                                        }];
    
    return objectMapping;
}

@end

@implementation IQService

- (id)initWithURL:(NSString *)url andSession:(id)session {
    self = [super initWithURL:url andSession:session];
    if (self) {
        self.responseClass = [IQServiceResponse class];
    }
    return self;
}

#pragma mark - Public methods

- (NSString*)storeFileName {
    return @"IQ300";
}

- (void)loginWithEmail:(NSString*)email password:(NSString*)password handler:(RequestCompletionHandler)handler {
    NSDictionary * parameters = @{ @"email"    : NSStringEmptyForNil(email),
                                   @"password" : NSStringEmptyForNil(password) };
    [self postObject:nil
                path:@"/api/v1/sessions"
          parameters:parameters
             handler:^(BOOL success, IQToken * token, NSData *responseData, NSError *error) {
                     if (success && token) {
                         self.session = [IQSession sessionWithEmail:email andPassword:password token:token.token];
                     }
                     
                 if(handler) {
                    handler(success, responseData, error);
                 }
             }];
}

- (void)logout {
    [self deleteObject:nil
                  path:@"/api/v1/sessions"
            parameters:@{ @"access_token" : self.session.token }
               handler:nil];
    self.session = nil;
}

- (void)userInfoWithHandler:(ObjectLoaderCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/users/current"
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

- (void)notificationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per search:(NSString*)search handler:(ObjectLoaderCompletionHandler)handler {
    [self notificationsUnread:unread page:page per:per search:search sort:IQSortDirectionNo handler:handler];
}

- (void)notificationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per search:(NSString*)search sort:(IQSortDirection)sort handler:(ObjectLoaderCompletionHandler)handler {
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    if (unread) {
        parameters[@"unread"] = unread;
    }
    
    if (page) {
        parameters[@"page"] = page;
    }
    if (per) {
        parameters[@"per"] = per;
    }
    if (search) {
        parameters[@"search"] = unread;
    }
    
    NSString * sortDirection = (sort == IQSortDirectionAscending) ? @"?sort=asc" : @"?sort=desc";
    
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/notifications%@", (sort != IQSortDirectionNo) ? sortDirection : @""]
                parameters:parameters
                   handler:handler];
}

- (void)notificationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per sort:(IQSortDirection)sort handler:(ObjectLoaderCompletionHandler)handler {
    [self notificationsUnread:unread page:page per:per search:nil sort:sort handler:handler];
}

- (void)markNotificationAsRead:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler {
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/notifications/%@", notificationId]
         parameters:nil
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if(handler) {
                    handler(success, responseData, error);
                }
            }];
}

- (void)marAllkNotificationAsReadWithHandler:(RequestCompletionHandler)handler {
    [self putObject:nil
               path:@"/api/v1/notifications/read_all"
         parameters:nil
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if(handler) {
                    handler(success, responseData, error);
                }
            }];
}

- (void)notificationsCountWithHandler:(ObjectLoaderCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/notifications/counters"
                parameters:nil
                   handler:handler];
}

#pragma mark - Private methods

- (void)initDescriptors {
    RKResponseDescriptor * descriptor = [IQServiceResponse responseDescriptorForClass:[IQToken class]
                                                                               method:RKRequestMethodPOST
                                                                          pathPattern:@"/api/v1/sessions"
                                                                          fromKeyPath:nil
                                                                                store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodAny
                                                         pathPattern:nil
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassServerError)];
    [self.objectManager addResponseDescriptor:descriptor];


    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodDELETE
                                                         pathPattern:@"/api/v1/sessions"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQNotificationsHolder class]//[IQNotification class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/notifications"
                                                   fromKeyPath:nil//@"notifications"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQUser class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/users/current"
                                                   fromKeyPath:@"user"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"/api/v1/notifications/:id"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"/api/v1/notifications/read_all"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[NotificationsCount class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/notifications/counters"
                                                   fromKeyPath:@"notification_counters"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

}

- (void)processAuthorizationForOperation:(RKObjectRequestOperation *)operation {
    if(self.session) {
        NSString * token = [NSString stringWithFormat:@"%@ %@", self.session.tokenType, self.session.token];
        [((NSMutableURLRequest*)operation.HTTPRequestOperation.request) addValue:token forHTTPHeaderField:@"Authorization"];
    }
}

@end
