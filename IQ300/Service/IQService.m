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

@implementation IQService

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
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"unread" : NSObjectNullForNil(unread),
                                                                  @"page"   : NSObjectNullForNil(page),
                                                                  @"per"    : NSObjectNullForNil(per),
                                                                  @"search" : NSStringNullForNil(search)
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:@"/api/v1/notifications"
                parameters:parameters
                   handler:handler];
}

- (void)notificationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per sort:(IQSortDirection)sort handler:(ObjectLoaderCompletionHandler)handler {
    [self notificationsUnread:unread page:page per:per search:nil sort:sort handler:handler];
}

- (void)notificationsAfterId:(NSNumber*)notificationId
                      unread:(NSNumber*)unread
                        page:(NSNumber*)page
                         per:(NSNumber*)per
                        sort:(IQSortDirection)sort
                     handler:(ObjectLoaderCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"id_more_than" : NSObjectNullForNil(notificationId),
                                                                  @"unread"       : NSObjectNullForNil(unread),
                                                                  @"page"         : NSObjectNullForNil(page),
                                                                  @"per"          : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:@"/api/v1/notifications"
                parameters:parameters
                   handler:handler];
}

- (void)notificationsBeforeId:(NSNumber*)notificationId
                       unread:(NSNumber*)unread
                         page:(NSNumber*)page
                          per:(NSNumber*)per
                         sort:(IQSortDirection)sort
                      handler:(ObjectLoaderCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"id_less_than" : NSObjectNullForNil(notificationId),
                                                                  @"unread"       : NSObjectNullForNil(unread),
                                                                  @"page"         : NSObjectNullForNil(page),
                                                                  @"per"          : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:@"/api/v1/notifications"
                parameters:parameters
                   handler:handler];
}

- (void)notificationsWithIds:(NSArray*)ids handler:(ObjectLoaderCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/notifications"
                parameters:@{ @"by_ids" : ids, @"per" : @(NSIntegerMax) }
                   handler:handler];
}

- (void)unreadNotificationIdsWithHandler:(ObjectLoaderCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/notifications/unread_ids"
                parameters:nil
                   handler:^(BOOL success, IQNotificationIds * holder, NSData *responseData, NSError *error) {
                       if(success && holder) {
                           if(handler) {
                               handler(success, holder.notificationIds, responseData, error);
                           }
                       }
                       else if(handler) {
                           handler(success, holder, responseData, error);
                       }
                   }];
}

- (void)unreadNotificationsGroupIdsWithHandler:(ObjectLoaderCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/notifications/unread_group_sids"
                parameters:nil
                   handler:^(BOOL success, IQNotificationsGroupIds * holder, NSData *responseData, NSError *error) {
                       if(success && holder) {
                           if(handler) {
                               handler(success, holder.groupIds, responseData, error);
                           }
                       }
                       else if(handler) {
                           handler(success, holder, responseData, error);
                       }
                   }];
}

- (void)notificationsGroupAfterId:(NSNumber*)notificationId
                           unread:(NSNumber*)unread
                             page:(NSNumber*)page
                              per:(NSNumber*)per
                             sort:(IQSortDirection)sort
                          handler:(ObjectLoaderCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"id_more_than" : NSObjectNullForNil(notificationId),
                                                                  @"unread"       : NSObjectNullForNil(unread),
                                                                  @"page"         : NSObjectNullForNil(page),
                                                                  @"per"          : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:@"/api/v1/notifications/groups"
                parameters:parameters
                   handler:handler];
}

- (void)notificationsGroupBeforeId:(NSNumber*)notificationId
                            unread:(NSNumber*)unread
                              page:(NSNumber*)page
                               per:(NSNumber*)per
                              sort:(IQSortDirection)sort
                           handler:(ObjectLoaderCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"id_less_than" : NSObjectNullForNil(notificationId),
                                                                  @"unread"       : NSObjectNullForNil(unread),
                                                                  @"page"         : NSObjectNullForNil(page),
                                                                  @"per"          : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:@"/api/v1/notifications/groups"
                parameters:parameters
                   handler:handler];
}

- (void)notificationsGroupUpdatedAfter:(NSDate*)date
                                unread:(NSNumber*)unread
                                  page:(NSNumber*)page
                                   per:(NSNumber*)per
                                  sort:(IQSortDirection)sort
                               handler:(ObjectLoaderCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"updated_at_after" : NSObjectNullForNil(date),
                                                                  @"unread"           : NSObjectNullForNil(unread),
                                                                  @"page"             : NSObjectNullForNil(page),
                                                                  @"per"              : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }

    [self getObjectsAtPath:@"/api/v1/notifications/groups"
                parameters:parameters
                   handler:handler];
}

- (void)notificationsForGroupWithId:(NSNumber*)anyNotificationId
                            afterId:(NSNumber*)notificationId
                             unread:(NSNumber*)unread
                               page:(NSNumber*)page
                                per:(NSNumber*)per
                               sort:(IQSortDirection)sort
                            handler:(ObjectLoaderCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"id_more_than" : NSObjectNullForNil(notificationId),
                                                                  @"unread"       : NSObjectNullForNil(unread),
                                                                  @"page"         : NSObjectNullForNil(page),
                                                                  @"per"          : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/notifications/%@/children", anyNotificationId]
                parameters:parameters
                   handler:handler];
}

- (void)notificationsForGroupWithId:(NSNumber*)anyNotificationId
                           beforeId:(NSNumber*)notificationId
                             unread:(NSNumber*)unread
                               page:(NSNumber*)page
                                per:(NSNumber*)per
                               sort:(IQSortDirection)sort
                              handler:(ObjectLoaderCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"id_less_than" : NSObjectNullForNil(notificationId),
                                                                  @"unread"       : NSObjectNullForNil(unread),
                                                                  @"page"         : NSObjectNullForNil(page),
                                                                  @"per"          : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/notifications/%@/children", anyNotificationId]
                parameters:parameters
                   handler:handler];
}

- (void)notificationsForGroupWithId:(NSNumber*)anyNotificationId
                       updatedAfter:(NSDate*)updatedAfter
                             unread:(NSNumber*)unread
                               page:(NSNumber*)page
                                per:(NSNumber*)per
                               sort:(IQSortDirection)sort
                            handler:(ObjectLoaderCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"updated_at_after" : NSObjectNullForNil(updatedAfter),
                                                                  @"unread"           : NSObjectNullForNil(unread),
                                                                  @"page"             : NSObjectNullForNil(page),
                                                                  @"per"              : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/notifications/%@/children", anyNotificationId]
                parameters:parameters
                   handler:handler];
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

- (void)markAllNotificationsAsReadWithHandler:(RequestCompletionHandler)handler {
    [self putObject:nil
               path:@"/api/v1/notifications/read_all"
         parameters:nil
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if(handler) {
                    handler(success, responseData, error);
                }
            }];
}

- (void)markNotificationsGroupAsReadWithId:(NSNumber*)notificationId handler:(ObjectLoaderCompletionHandler)handler {
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/notifications/%@/read_group", notificationId]
         parameters:nil
            handler:handler];
}

- (void)markAllNotificationGroupsAsReadWithHandler:(ObjectLoaderCompletionHandler)handler {
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/notifications/read_all_groups"]
         parameters:nil
            handler:handler];
}

- (void)notificationsCountWithHandler:(ObjectLoaderCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/notifications/counters"
                parameters:nil
                   handler:handler];
}

- (void)notificationsGroupCountWithHandler:(ObjectLoaderCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/notifications/group_counters"
                parameters:nil
                   handler:handler];
}

- (void)notificationsCountForGroupWithId:(NSNumber*)anyNotificationId handler:(ObjectLoaderCompletionHandler)handler {
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/notifications/%@/group_counter", anyNotificationId]
                parameters:nil
                   handler:handler];
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
                    path:@"/api/v1/devices"
              parameters:parameters
                 handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                     if(handler) {
                         handler(success, responseData, error);
                     }
                 }];
    }
}

- (void)acceptNotificationWithId:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler {
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/notifications/%@/accept", notificationId]
         parameters:nil
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if(handler) {
                    handler(success, responseData, error);
                }
            }];
}

- (void)declineNotificationWithId:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler {
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/notifications/%@/decline", notificationId]
         parameters:nil
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if(handler) {
                    handler(success, responseData, error);
                }
            }];
}

#pragma mark - Private methods

- (void)processAuthorizationForOperation:(RKObjectRequestOperation *)operation {
    if(self.session) {
        NSString * token = [NSString stringWithFormat:@"%@ %@", self.session.tokenType, self.session.token];
        [((NSMutableURLRequest*)operation.HTTPRequestOperation.request) addValue:token forHTTPHeaderField:@"Authorization"];
    }
}

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
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQNotification class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/notifications"
                                                   fromKeyPath:@"notifications"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQNotificationsHolder class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/notifications/:id/children"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQNotificationGroupsHolder class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/notifications/groups"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQNotificationIds class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/notifications/unread_ids"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQNotificationsGroupIds class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/notifications/unread_group_sids"
                                                   fromKeyPath:nil
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
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQNotificationsGroup class]
                                                        method:RKRequestMethodPUT
                                                   pathPattern:@"/api/v1/notifications/:id/read_group"
                                                   fromKeyPath:@"notification_group"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQGroupCounter class]
                                                        method:RKRequestMethodPUT
                                                   pathPattern:@"/api/v1/notifications/read_all_groups"
                                                   fromKeyPath:@"unread_groups"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQCounters class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/notifications/counters"
                                                   fromKeyPath:@"notification_counters"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQCounters class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/notifications/group_counters"
                                                   fromKeyPath:@"notification_group_counters"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQCounters class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/notifications/:id/group_counter"
                                                   fromKeyPath:@"notification_group_counter"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQConversation class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/conversations"
                                                   fromKeyPath:@"conversations"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQConversation class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/conversations/:id"
                                                   fromKeyPath:@"conversation"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQConversation class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"/api/v1/conversations"
                                                   fromKeyPath:@"conversation"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"/api/v1/discussions/:id"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQDiscussion class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/discussions/:id"
                                                   fromKeyPath:@"discussion"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQCounters class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/conversations/counters"
                                                   fromKeyPath:@"conversation_counters"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQComment class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/discussions/:id/comments"
                                                   fromKeyPath:@"comments"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQComment class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"/api/v1/discussions/:id/comments"
                                                   fromKeyPath:@"comment"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQComment class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/discussions/:id/comments/:id"
                                                   fromKeyPath:@"comment"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [IQServiceResponse responseDescriptorForClass:[IQAttachment class]
                                                        method:RKRequestMethodPOST
                                                   pathPattern:@"/api/v1/attachments"
                                                   fromKeyPath:@"attachment"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQContact class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/contacts"
                                                   fromKeyPath:@"contacts"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPOST
                                                         pathPattern:@"/api/v1/devices"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"/api/v1/notifications/:id/accept"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];

    descriptor = [RKResponseDescriptor responseDescriptorWithMapping:[IQServiceResponse objectMapping]
                                                              method:RKRequestMethodPUT
                                                         pathPattern:@"/api/v1/notifications/:id/decline"
                                                             keyPath:nil
                                                         statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [self.objectManager addResponseDescriptor:descriptor];
    
    //Tasks
    descriptor = [IQServiceResponse responseDescriptorForClass:[IQTasksHolder class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/tasks"
                                                   fromKeyPath:nil
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[TaskFilterCounters class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/tasks/filter_counters"
                                                   fromKeyPath:@"filter_counters"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
    
    descriptor = [IQServiceResponse responseDescriptorForClass:[TasksMenuCounters class]
                                                        method:RKRequestMethodGET
                                                   pathPattern:@"/api/v1/tasks/menu_counters"
                                                   fromKeyPath:@"menu_counters"
                                                         store:self.objectManager.managedObjectStore];
    
    [self.objectManager addResponseDescriptor:descriptor];
}

@end
