//
//  MessagesModel.h
//  IQ300
//
//  Created by Tayphoon on 03.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@interface MessagesModel : NSObject<IQTableModel>

@property (nonatomic, assign) BOOL loadUnreadOnly;
@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;
- (void)reloadFirstPartWithCompletion:(void (^)(NSError * error))completion;

- (NSInteger)totalItemsCount;
- (NSInteger)unreadItemsCount;

- (void)updateCountersWithCompletion:(void (^)(NSError * error))completion;

- (void)setSubscribedToSystemWakeNotifications:(BOOL)subscribed;

- (void)markConversationAsReadAtIndexPath:(NSIndexPath*)indexPath completion:(void (^)(NSError * error))completion;

@end
