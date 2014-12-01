//
//  NotificationsModel.h
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@class IQNotification;

@interface NotificationsModel : NSObject<IQTableModel>

@property (nonatomic, assign) BOOL loadUnreadOnly;
@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;

- (NSInteger)totalItemsCount;
- (NSInteger)unreadItemsCount;

- (void)markNotificationAsReadAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion;
- (void)markAllNotificationAsReadWithCompletion:(void (^)(NSError * error))completion;

- (void)updateCountersWithCompletion:(void (^)(NSError * error))completion;

@end
