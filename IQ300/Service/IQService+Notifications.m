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
    
    [self getObjectsAtPath:@"/api/v1/notifications"
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
    
    [self getObjectsAtPath:@"/api/v1/notifications"
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
    
    [self getObjectsAtPath:@"/api/v1/notifications"
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
    
    [self getObjectsAtPath:@"/api/v1/notifications"
                parameters:parameters
                   handler:handler];
}

- (void)notificationsWithIds:(NSArray*)ids handler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/notifications"
                parameters:@{ @"by_ids" : ids, @"per" : @(NSIntegerMax) }
                   handler:handler];
}

- (void)unreadNotificationIdsWithHandler:(ObjectRequestCompletionHandler)handler {
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

- (void)unreadNotificationsGroupIdsWithHandler:(ObjectRequestCompletionHandler)handler {
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
    
    [self getObjectsAtPath:@"/api/v1/notifications/groups"
                parameters:parameters
                   handler:handler];
}

- (void)notificationsGroupBeforeId:(NSNumber*)notificationId
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
    
    [self getObjectsAtPath:@"/api/v1/notifications/groups"
                parameters:parameters
                   handler:handler];
}

- (void)notificationsGroupUpdatedAfter:(NSDate*)date
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
                            handler:(ObjectRequestCompletionHandler)handler {
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

- (void)markNotificationsGroupAsReadWithId:(NSNumber*)notificationId handler:(ObjectRequestCompletionHandler)handler {
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/notifications/%@/read_group", notificationId]
         parameters:nil
            handler:handler];
}

- (void)markAllNotificationGroupsAsReadWithHandler:(ObjectRequestCompletionHandler)handler {
    [self putObject:nil
               path:[NSString stringWithFormat:@"/api/v1/notifications/read_all_groups"]
         parameters:nil
            handler:handler];
}

- (void)notificationsCountWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/notifications/counters"
                parameters:nil
                   handler:handler];
}

- (void)notificationsGroupCountWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"/api/v1/notifications/group_counters"
                parameters:nil
                   handler:handler];
}

- (void)notificationsCountForGroupWithId:(NSNumber*)anyNotificationId handler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:[NSString stringWithFormat:@"/api/v1/notifications/%@/group_counter", anyNotificationId]
                parameters:nil
                   handler:handler];
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

@end
