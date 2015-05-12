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

- (void)notificationsWithIds:(NSArray*)ids handler:(ObjectRequestCompletionHandler)handler;

- (void)unreadNotificationIdsWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)unreadNotificationsGroupIdsWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)notificationsGroupAfterId:(NSNumber*)notificationId
                           unread:(NSNumber*)unread
                             page:(NSNumber*)page
                              per:(NSNumber*)per
                             sort:(IQSortDirection)sort
                          handler:(ObjectRequestCompletionHandler)handler;

- (void)notificationsGroupBeforeId:(NSNumber*)notificationId
                            unread:(NSNumber*)unread
                              page:(NSNumber*)page
                               per:(NSNumber*)per
                              sort:(IQSortDirection)sort
                           handler:(ObjectRequestCompletionHandler)handler;

- (void)notificationsGroupUpdatedAfter:(NSDate*)date
                                unread:(NSNumber*)unread
                                  page:(NSNumber*)page
                                   per:(NSNumber*)per
                                  sort:(IQSortDirection)sort
                               handler:(ObjectRequestCompletionHandler)handler;

/**
 *  Get notifications for group
 *
 *  @param anyNotificationId  Id of any notification in group (group secondary identifire)
 *  @param notificationId     Id of notification using in filter as after parameter
 *  @param unread             Return only unread notifications if true
 *  @param page               Page offset
 *  @param per                Count of notifications at page
 *  @param sort               Sort direction
 *  @param handler            Action handler
 */
- (void)notificationsForGroupWithId:(NSNumber*)anyNotificationId
                            afterId:(NSNumber*)notificationId
                             unread:(NSNumber*)unread
                               page:(NSNumber*)page
                                per:(NSNumber*)per
                               sort:(IQSortDirection)sort
                            handler:(ObjectRequestCompletionHandler)handler;

/**
 *  Get notifications for group
 *
 *  @param anyNotificationId  Id of any notification in group (group secondary identifire)
 *  @param notificationId     Id of notification using in filter as before parameter
 *  @param unread             Return only unread notifications if true
 *  @param page               Page offset
 *  @param per                Count of notifications at page
 *  @param sort               Sort direction
 *  @param handler            Action handler
 */
- (void)notificationsForGroupWithId:(NSNumber*)anyNotificationId
                           beforeId:(NSNumber*)notificationId
                             unread:(NSNumber*)unread
                               page:(NSNumber*)page
                                per:(NSNumber*)per
                               sort:(IQSortDirection)sort
                            handler:(ObjectRequestCompletionHandler)handler;

/**
 *  Get notifications for group
 *
 *  @param anyNotificationId  Id of any notification in group (group secondary identifire)
 *  @param updatedAfter       Date of notification update using in filter as after parameter
 *  @param unread             Return only unread notifications if true
 *  @param page               Page offset
 *  @param per                Count of notifications at page
 *  @param sort               Sort direction
 *  @param handler            Action handler
 */
- (void)notificationsForGroupWithId:(NSNumber*)anyNotificationId
                       updatedAfter:(NSDate*)updatedAfter
                             unread:(NSNumber*)unread
                               page:(NSNumber*)page
                                per:(NSNumber*)per
                               sort:(IQSortDirection)sort
                            handler:(ObjectRequestCompletionHandler)handler;

- (void)markNotificationAsRead:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler;

- (void)markAllNotificationsAsReadWithHandler:(RequestCompletionHandler)handler;

/**
 *  Marl all notifications in group as read
 *
 *  @param notificationId Id of any notification in group (group secondary identifire)
 *  @param handler        Action handler
 */
- (void)markNotificationsGroupAsReadWithId:(NSNumber*)notificationId handler:(ObjectRequestCompletionHandler)handler;

- (void)markAllNotificationGroupsAsReadWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)notificationsCountWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)notificationsGroupCountWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)notificationsCountForGroupWithId:(NSNumber*)anyNotificationId handler:(ObjectRequestCompletionHandler)handler;

- (void)acceptNotificationWithId:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler;

- (void)declineNotificationWithId:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler;

@end
