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

- (void)loadNextPartWithCompletion:(void (^)(NSError * error, NSIndexPath *indexPath))completion;

- (void)setSubscribedToNotifications:(BOOL)subscribed;

- (void)sendComment:(NSString*)comment
         attachment:(id)attachment
           fileName:(NSString*)fileName
           mimeType:(NSString*)mimeType
     withCompletion:(void (^)(NSError * error))completion;

- (void)resendLocalComment:(IQComment*)comment completion:(void (^)(NSError * error))completion;

- (void)deleteComment:(IQComment*)comment completion:(void (^)(NSError * error))completion;

- (void)deleteLocalComment:(IQComment*)comment;

- (NSIndexPath*)indexPathForCommentWithId:(NSNumber*)commentId;

- (void)markCommentsReadedAtIndexPaths:(NSArray*)indexPaths;

@end
