//
//  IQService+Notifications.m
//  IQ300
//
//  Created by Tayphoon on 12.05.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQService+Notifications.h"
#import "IQObjects.h"

@implementation IQService (Notifications)

- (void)notificationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per search:(NSString*)search handler:(ObjectRequestCompletionHandler)handler {
    [self notificationsUnread:unread page:page per:per search:search sort:IQSortDirectionNo handler:handler];
}

- (void)notificationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per search:(NSString*)search sort:(IQSortDirection)sort handler:(ObjectRequestCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"unread" : NSObjectNullForNil(unread),
                                                                  @"page"   : NSObjectNullForNil(page),
                                                                  @"per"    : NSObjectNullForNil(per),
                                                                  @"search" : NSStringNullForNil(search)
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:@"/api/v2/notifications"
                parameters:parameters
                   handler:handler];
}

- (void)notificationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per sort:(IQSortDirection)sort handler:(ObjectRequestCompletionHandler)handler {
    [self notificationsUnread:unread page:page per:per search:nil sort:sort handler:handler];
}

- (void)notificationsAfterId:(NSNumber*)notificationId
                      unread:(NSNumber*)unread
                        page:(NSNumber*)page
                         per:(NSNumber*)per
                        sort:(IQSortDirection)sort
                     handler:(ObjectRequestCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"id_more_than" : NSObjectNullForNil(notificationId),
                                                                  @"unread"       : NSObjectNullForNil(unread),
                                                                  @"page"         : NSObjectNullForNil(page),
                                                                  @"per"          : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:@"/api/v2/notifications"
                parameters:parameters
                   handler:handler];
}

- (void)notificationsBeforeId:(NSNumber*)notificationId
                       unread:(NSNumber*)unread
                         page:(NSNumber*)page
                          per:(NSNumber*)per
                         sort:(IQSortDirection)sort
                      handler:(ObjectRequestCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"id_less_than" : NSObjectNullForNil(notificationId),
                                                                  @"unread"       : NSObjectNullForNil(unread),
                                                                  @"page"         : NSObjectNullForNil(page),
                                                                  @"per"          : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:@"/api/v2/notifications"
                parameters:parameters
                   handler:handler];
}

- (void)notificationsUpdatedAfter:(NSDate*)date
                           unread:(NSNumber*)unread
                             page:(NSNumber*)page
                              per:(NSNumber*)per
                             sort:(IQSortDirection)sort
                          handler:(ObjectRequestCompletionHandler)handler {
    NSMutableDictionary * parameters = IQParametersExcludeEmpty(@{
                                                                  @"updated_at_after" : NSObjectNullForNil(date),
                                                                  @"unread"           : NSObjectNullForNil(unread),
                                                                  @"page"             : NSObjectNullForNil(page),
                                                                  @"per"              : NSObjectNullForNil(per),
                                                                  }).mutableCopy;
    
    if(sort != IQSortDirectionNo) {
        parameters[@"sort"] = IQSortDirectionToString(sort);
    }
    
    [self getObjectsAtPath:@"/api/v2/notifications"
                parameters:parameters
                   handler:handler];
}

- (void)notificationsWithIds:(NSArray*)ids handler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v2/notifications"
                parameters:@{ @"by_ids" : ids, @"per" : @(NSIntegerMax) }
                   handler:handler];
}

- (void)unreadNotificationIdsWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v2/notifications/unread_ids"
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

- (void)markNotificationAsRead:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler {
    [self putObject:nil
               path:@"/api/v2/notifications/read"
         parameters:@{ @"notification_ids" : (notificationId) ? @[notificationId] : [NSNull null] }
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if(handler) {
                    handler(success, responseData, error);
                }
            }];
}

- (void)markAllNotificationsAsReadWithHandler:(RequestCompletionHandler)handler {
    [self putObject:nil
               path:@"/api/v2/notifications/read_all"
         parameters:nil
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if(handler) {
                    handler(success, responseData, error);
                }
            }];
}

- (void)notificationsCountWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v2/notifications/counters"
                parameters:nil
                   handler:handler];
}

- (void)acceptNotificationWithId:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler {
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v2/notifications/%@/accept", notificationId]
         parameters:nil
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if(handler) {
                    handler(success, responseData, error);
                }
            }];
}

- (void)declineNotificationWithId:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler {
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v2/notifications/%@/decline", notificationId]
         parameters:nil
            handler:^(BOOL success, id object, NSData *responseData, NSError *error) {
                if(handler) {
                    handler(success, responseData, error);
                }
            }];
}

@end
