//
//  NotificationsModel.h
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@class IQNotification;
@class IQCounters;

@interface NotificationsModel : NSObject<IQTableModel>

@property (nonatomic, assign) BOOL loadUnreadOnly;
@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

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
- (void)reloadFirstPartWithCompletion:(void (^)(NSError * error))completion;

- (NSInteger)totalItemsCount;
- (NSInteger)unreadItemsCount;

- (void)markNotificationAsReadAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion;
- (void)markAllNotificationAsReadWithCompletion:(void (^)(NSError * error))completion;

- (void)updateCountersWithCompletion:(void (^)(IQCounters * counters, NSError * error))completion;

- (void)setSubscribedToNotifications:(BOOL)subscribed;

- (void)acceptNotification:(IQNotification*)notification completion:(void (^)(NSError * error))completion;

- (void)declineNotification:(IQNotification*)notification completion:(void (^)(NSError * error))completion;

@end
