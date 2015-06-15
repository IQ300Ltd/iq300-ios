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
@class ALAsset;

@protocol DiscussionModelDelegate <IQTableModelDelegate>

@optional
- (void)model:(DiscussionModel*)model newComment:(IQComment*)comment;

@end

@interface DiscussionModel : NSObject<IQTableModel>

@property (nonatomic, strong) IQDiscussion * discussion;
@property (nonatomic, strong) NSNumber * companionId;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, weak) id<DiscussionModelDelegate> delegate;

- (id)initWithDiscussion:(IQDiscussion*)discussion;

- (BOOL)isItemExpandedAtIndexPath:(NSIndexPath*)indexPath;

- (BOOL)isCellExpandableAtIndexPath:(NSIndexPath*)indexPath;

- (void)setItemExpanded:(BOOL)expanded atIndexPath:(NSIndexPath*)indexPath;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;

- (void)reloadFirstPartWithCompletion:(void (^)(NSError * error))completion;

- (void)setSubscribedToNotifications:(BOOL)subscribed;

- (void)sendComment:(NSString*)comment
         attachment:(id)attachment
           fileName:(NSString*)fileName
           mimeType:(NSString*)mimeType
     withCompletion:(void (^)(NSError * error))completion;

- (void)resendLocalComment:(IQComment*)comment withCompletion:(void (^)(NSError * error))completion;

- (void)deleteComment:(IQComment*)comment completion:(void (^)(NSError * error))completion;

- (void)deleteLocalComment:(IQComment*)comment;

@end
