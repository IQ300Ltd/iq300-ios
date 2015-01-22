//
//  CommentsModel.h
//  IQ300
//
//  Created by Tayphoon on 24.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@class CommentsModel;
@class IQDiscussion;
@class IQComment;
@class ALAsset;

@protocol CommentsModelDelegate <IQTableModelDelegate>

@optional
- (void)model:(CommentsModel*)model newComment:(IQComment*)comment;

@end

@interface CommentsModel : NSObject<IQTableModel>

@property (nonatomic, strong) IQDiscussion * discussion;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, weak) id<CommentsModelDelegate> delegate;

- (id)initWithDiscussion:(IQDiscussion*)discussion;

- (BOOL)isItemExpandedAtIndexPath:(NSIndexPath*)indexPath;

- (BOOL)isCellExpandableAtIndexPath:(NSIndexPath*)indexPath;

- (void)setItemExpanded:(BOOL)expanded atIndexPath:(NSIndexPath*)indexPath;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;

- (void)reloadFirstPartWithCompletion:(void (^)(NSError * error))completion;

- (void)setSubscribedToNotifications:(BOOL)subscribed;

- (void)sendComment:(NSString*)comment
    attachmentAsset:(ALAsset*)asset
           fileName:(NSString*)fileName
     attachmentType:(NSString*)type
     withCompletion:(void (^)(NSError * error))completion;

- (void)resendLocalComment:(IQComment*)comment withCompletion:(void (^)(NSError * error))completion;

- (void)deleteComment:(IQComment*)comment;

- (NSIndexPath*)indexPathForCommentWithId:(NSNumber*)commentId;

@end
