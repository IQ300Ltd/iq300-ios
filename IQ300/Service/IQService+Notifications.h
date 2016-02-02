//
//  IQService+Notifications.h
//  IQ300
//
//  Created by Tayphoon on 12.05.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQService.h"

@interface IQService (Notifications)

/**
 Request user notifications. There is an opportunity to receive notifications portions.
 
 @param unread If flag i set return only unread notifications(optional).
 @param page Serial number of portions(optional).
 @param per Portion size(optional).
 @param search Search text using as filter(optional).
 @param handler Handler block. Look `ObjectLoaderCompletionHandler`.
 */
- (void)notificationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per search:(NSString*)search handler:(ObjectRequestCompletionHandler)handler;

- (void)notificationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per sort:(IQSortDirection)sort handler:(ObjectRequestCompletionHandler)handler;

- (void)notificationsAfterId:(NSNumber*)notificationId
                      unread:(NSNumber*)unread
                        page:(NSNumber*)page
                         per:(NSNumber*)per
                        sort:(IQSortDirection)sort
                     handler:(ObjectRequestCompletionHandler)handler;

- (void)notificationsBeforeId:(NSNumber*)notificationId
                       unread:(NSNumber*)unread
                         page:(NSNumber*)page
                          per:(NSNumber*)per
                         sort:(IQSortDirection)sort
                      handler:(ObjectRequestCompletionHandler)handler;

- (void)notificationsUpdatedAfter:(NSDate*)date
                           unread:(NSNumber*)unread
                             page:(NSNumber*)page
                              per:(NSNumber*)per
                             sort:(IQSortDirection)sort
                          handler:(ObjectRequestCompletionHandler)handler;

- (void)notificationsWithIds:(NSArray*)ids handler:(ObjectRequestCompletionHandler)handler;

- (void)unreadNotificationIdsWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)markNotificationAsRead:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler;

- (void)markAllNotificationsAsReadWithHandler:(RequestCompletionHandler)handler;

- (void)notificationsCountWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)acceptNotificationWithId:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler;

- (void)declineNotificationWithId:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler;

@end
