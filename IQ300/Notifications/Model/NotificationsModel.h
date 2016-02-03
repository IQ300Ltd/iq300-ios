//
//  NotificationsModel.h
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@class IQNotification;
@class IQNotificationCounters;

@interface NotificationsModel : NSObject<IQTableModel>

@property (nonatomic, assign) BOOL loadUnreadOnly;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, weak) id<IQTableModelDelegate> delegate;


+ (void)markNotificationsRelatedToComments:(NSArray*)comments;

/**
 UpdateModelWithCompletion. Load new data.
 
 @param completion handler.

 */
- (void)updateModelWithCompletion:(void (^)(NSError * error))completion;

/**
 Load data from history.
 
 @param completion handler.
 
 */
- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;

- (NSInteger)unreadItemsCount;

- (void)markNotificationAsReadAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion;
- (void)markAllNotificationAsReadWithCompletion:(void (^)(NSError * error))completion;

- (void)updateCountersWithCompletion:(void (^)(IQNotificationCounters * counters, NSError * error))completion;

- (void)resubscribeToIQNotifications;

- (void)unsubscribeFromIQNotifications;

- (void)acceptNotification:(IQNotification*)notification completion:(void (^)(NSError * error))completion;

- (void)declineNotification:(IQNotification*)notification completion:(void (^)(NSError * error))completion;

@end
