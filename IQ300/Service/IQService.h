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

- (void)loginWithEmail:(NSString*)email password:(NSString*)password handler:(RequestCompletionHandler)handler;
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

- (void)notificationsAfterId:(NSNumber*)notificationId unread:(NSNumber*)unread per:(NSNumber*)per sort:(IQSortDirection)sort handler:(ObjectLoaderCompletionHandler)handler;

- (void)notificationsBeforeId:(NSNumber*)notificationId unread:(NSNumber*)unread per:(NSNumber*)per sort:(IQSortDirection)sort handler:(ObjectLoaderCompletionHandler)handler;

- (void)notificationsWithIds:(NSArray*)ids handler:(ObjectLoaderCompletionHandler)handler;

- (void)unreadNotificationIdsWithHandler:(ObjectLoaderCompletionHandler)handler;

- (void)markNotificationAsRead:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler;

- (void)markAllNotificationAsReadWithHandler:(RequestCompletionHandler)handler;

- (void)notificationsCountWithHandler:(ObjectLoaderCompletionHandler)handler;

- (void)registerDeviceForRemoteNotificationsWithToken:(NSString*)token handler:(RequestCompletionHandler)handler;

- (void)acceptNotificationWithId:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler;

- (void)declineNotificationWithId:(NSNumber*)notificationId handler:(RequestCompletionHandler)handler;


@end
