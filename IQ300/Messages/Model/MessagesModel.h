//
//  MessagesModel.h
//  IQ300
//
//  Created by Tayphoon on 03.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@class IQConversation;

@interface MessagesModel : NSObject<IQTableModel>

@property (nonatomic, assign) BOOL loadUnreadOnly;
@property (nonatomic, strong) NSString * filter;
@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

+ (void)createConversationWithRecipientId:(NSNumber*)recipientId completion:(void (^)(IQConversation * conv, NSError * error))completion;
+ (void)markConversationAsRead:(IQConversation*)conversation completion:(void (^)(NSError * error))completion;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;
- (void)reloadFirstPartWithCompletion:(void (^)(NSError * error))completion;
- (void)updateModelSourceControllerWithCompletion:(void (^)(NSError * error))completion;

- (NSInteger)totalItemsCount;
- (NSInteger)unreadItemsCount;

- (void)updateCountersWithCompletion:(void (^)(NSError * error))completion;

- (void)setSubscribedToNotifications:(BOOL)subscribed;

@end
