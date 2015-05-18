//
//  NGroupModel.h
//  IQ300
//
//  Created by Tayphoon on 29.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@class IQCounters;

@interface NotificationsGroupModel : NSObject<IQTableModel>

@property (nonatomic, assign) BOOL loadUnreadOnly;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

+ (BOOL)isGroupHasUnreadNotificationsWithId:(NSString*)groupSid;

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

- (void)markNotificationsAsReadAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion;
- (void)markAllNotificationAsReadWithCompletion:(void (^)(NSError * error))completion;

- (void)updateCountersWithCompletion:(void (^)(IQCounters * counters, NSError * error))completion;

- (void)setSubscribedToNotifications:(BOOL)subscribed;

/**
 *  Accept last notification action and mark group as readed
 *
 *  @param indexPath  indexPath of group
 *  @param completion completion handler
 */
- (void)acceptNotificationsGroupAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion;

/**
 *  Decline last notification action and mark group as readed
 *
 *  @param indexPath  indexPath of group
 *  @param completion completion handler
 */
- (void)declineNotificationsGroupAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion;

@end
