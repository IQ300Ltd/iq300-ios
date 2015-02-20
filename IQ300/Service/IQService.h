//
//  IQService.h
//  IQ300
//
//  Created by Tayphoon on 13.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "TCService+Subclass.h"
#import "IQSession.h"

#define SERVICE_REGISTRATION_URL [NSString stringWithFormat:@"%@/%@", SERVICE_URL, @"users/sign_up"]
#define SERVICE_RESET_PASSWORD_URL [NSString stringWithFormat:@"%@/%@", SERVICE_URL, @"users/password/new"]

typedef NS_ENUM(NSUInteger, IQSortDirection) {
    IQSortDirectionNo = -1,
    IQSortDirectionAscending  = 0,
    IQSortDirectionDescending = 1,
};

/**
 ParametersExcludeEmpty.
 
 @param parameters. Look `NSDictionary`.
 @return Dictionary with out empty parameters
 */
extern NSDictionary * IQParametersExcludeEmpty(NSDictionary * parameters);

extern NSString * IQSortDirectionToString(IQSortDirection direction);

@interface IQService : TCService

@property (nonatomic, strong) IQSession * session;

- (void)loginWithDeviceToken:(NSString*)deviceToken email:(NSString*)email password:(NSString*)password handler:(RequestCompletionHandler)handler;
- (void)logout;

- (void)userInfoWithHandler:(ObjectLoaderCompletionHandler)handler;

/**
 Request user notifications. There is an opportunity to receive notifications portions.
 
 @param unread If flag i set return only unread notifications(optional).
 @param page Serial number of portions(optional).
 @param per Portion size(optional).
 @param search Search text using as filter(optional).
 @param handler Handler block. Look `ObjectLoaderCompletionHandler`.
 */
- (void)notificationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per search:(NSString*)search handler:(ObjectLoaderCompletionHandler)handler;

- (void)notificationsUnread:(NSNumber*)unread page:(NSNumber*)page per:(NSNumber*)per sort:(IQSortDirection)sort handler:(ObjectLoaderCompletionHandler)handler;

- (void)notificationsAfterId:(NSNumber*)notificationId
                      unread:(NSNumber*)unread
                        page:(NSNumber*)page
                         per:(NSNumber*)per
                        sort:(IQSortDirection)sort
                     handler:(ObjectLoaderCompletionHandler)handler;

- (void)notificationsBeforeId:(NSNumber*)notificationId
                       unread:(NSNumber*)unread
                         page:(NSNumber*)page
                          per:(NSNumber*)per
                         sort:(IQSortDirection)sort
                      handler:(ObjectLoaderCompletionHandler)handler;

- (void)notificationsWithIds:(NSArray*)ids handler:(ObjectLoaderCompletionHandler)handler;

- (void)unreadNotificationIdsWithHandler:(ObjectLoaderCompletionHandler)handler;

- (void)unreadNotificationsGroupIdsWithHandler:(ObjectLoaderCompletionHandler)handler;

- (void)notificationsGroupAfterId:(NSNumber*)notificationId
                           unread:(NSNumber*)unread
                             page:(NSNumber*)page
                              per:(NSNumber*)per
                             sort:(IQSortDirection)sort
                          handler:(ObjectLoaderCompletionHandler)handler;

- (void)notificationsGroupBeforeId:(NSNumber*)notificationId
                            unread:(NSNumber*)unread
                              page:(NSNumber*)page
                               per:(NSNumber*)per
                              sort:(IQSortDirection)sort
                           handler:(ObjectLoaderCompletionHandler)handler;

- (void)notificationsGroupUpdatedAfter:(NSDate*)date
                                unread:(NSNumber*)unread
                                  page:(NSNumber*)page
                                   per:(NSNumber*)per
                                  sort:(IQSortDirection)sort
                               handler:(ObjectLoaderCompletionHandler)handler;

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
                            handler:(ObjectLoaderCompletionHandler)handler;

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
                            handler:(ObjectLoaderCompletionHandler)handler;

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
                            handler:(ObjectLoaderCompletionHandler)handler;

- (void)markNotificationAsRead:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler;

- (void)markAllNotificationsAsReadWithHandler:(RequestCompletionHandler)handler;

/**
 *  Marl all notifications in group as read
 *
 *  @param notificationId Id of any notification in group (group secondary identifire)
 *  @param handler        Action handler
 */
- (void)markNotificationsGroupAsReadWithId:(NSNumber*)notificationId handler:(ObjectLoaderCompletionHandler)handler;

- (void)markAllNotificationGroupsAsReadWithHandler:(ObjectLoaderCompletionHandler)handler;

- (void)notificationsCountWithHandler:(ObjectLoaderCompletionHandler)handler;

- (void)notificationsGroupCountWithHandler:(ObjectLoaderCompletionHandler)handler;

- (void)notificationsCountForGroupWithId:(NSNumber*)anyNotificationId handler:(ObjectLoaderCompletionHandler)handler;

- (void)registerDeviceForRemoteNotificationsWithToken:(NSString*)token handler:(RequestCompletionHandler)handler;

- (void)acceptNotificationWithId:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler;

- (void)declineNotificationWithId:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler;


@end
