//
//  ConferenceInfoModel.h
//  IQ300
//
//  Created by Tayphoon on 13.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableModel+Subclass.h"

@class IQConversationMember;

@interface ConferenceInfoModel : IQTableModel

@property (nonatomic, strong) NSNumber * conversationId;
@property (nonatomic, strong) NSString * conversationTitle;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, readonly) NSArray * users;
@property (nonatomic, readonly) BOOL isAdministrator;

- (NSString*)placeholderForItemAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)isDeleteEnableForForItemAtIndexPath:(NSIndexPath*)indexPath;
- (void)updateTitle:(NSString*)title;

- (void)saveConversationTitleWithCompletion:(void (^)(NSError *))completion;
- (void)addMembersFromUsers:(NSArray*)users completion:(void (^)(NSError *))completion;
- (void)removeMember:(IQConversationMember*)member completion:(void (^)(NSError *))completion;
- (void)leaveConversationWithCompletion:(void (^)(NSError *))completion;

- (void)removeConversation;

@end
