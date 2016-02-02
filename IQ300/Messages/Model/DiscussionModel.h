//
//  DiscussionModel.h
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@class DiscussionModel;
@class IQDiscussion;
@class IQComment;
@class IQConversation;
@class IQAttachment;
@class ALAsset;
@class SharingAttachment;

@protocol DiscussionModelDelegate <IQTableModelDelegate>

@optional
- (void)model:(DiscussionModel*)model newComment:(IQComment*)comment;
- (void)model:(DiscussionModel *)model conversationTitleDidChanged:(NSString*)newTitle;
- (void)model:(DiscussionModel *)model memberDidRemovedWithId:(NSNumber*)userId;
- (void)model:(DiscussionModel *)model didAddMemberWith:(NSNumber*)userId;

@end

@interface DiscussionModel : NSObject<IQTableModel>

@property (nonatomic, strong) IQDiscussion * discussion;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, weak) id<DiscussionModelDelegate> delegate;

+ (void)conferenceFromConversationWithId:(NSNumber*)conversationId
                                 userIds:(NSArray*)userIds
                              completion:(void (^)(IQConversation * conversation, NSError *error))completion;

- (id)initWithDiscussion:(IQDiscussion*)discussion;

- (BOOL)isItemExpandedAtIndexPath:(NSIndexPath*)indexPath;

- (BOOL)isCellExpandableAtIndexPath:(NSIndexPath*)indexPath;

- (void)setItemExpanded:(BOOL)expanded atIndexPath:(NSIndexPath*)indexPath;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;

- (void)loadNextPartWithCompletion:(void (^)(NSError * error))completion;

- (void)setSubscribedToNotifications:(BOOL)subscribed;

- (void)sendComment:(NSString*)comment
         attachment:(id)attachment
           fileName:(NSString*)fileName
           mimeType:(NSString*)mimeType
     withCompletion:(void (^)(NSError * error))completion;

- (void)resendLocalComment:(IQComment*)comment withCompletion:(void (^)(NSError * error))completion;

- (void)deleteComment:(IQComment*)comment completion:(void (^)(NSError * error))completion;

- (void)deleteLocalComment:(IQComment*)comment;

- (void)markDiscussionAsReadedWithCompletion:(void (^)(NSError * error))completion;

- (BOOL)isDiscussionConference;

- (void)lockConversation;

- (void)unlockConversation;

@end

@interface DiscussionModel(Sharing)

- (void)sendComment:(NSString*)comment
         attachment:(SharingAttachment*)attachment
     withCompletion:(void (^)(NSError * error))completion;

@end
