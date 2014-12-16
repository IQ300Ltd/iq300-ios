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

@property (nonatomic, weak) IQDiscussion * discussion;
@property (nonatomic, strong) NSNumber * companionId;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, weak) id<DiscussionModelDelegate> delegate;

- (id)initWithDiscussion:(IQDiscussion*)discussion;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;

- (void)reloadFirstPartWithCompletion:(void (^)(NSError * error))completion;

- (void)setSubscribedToSystemWakeNotifications:(BOOL)subscribed;

- (void)sendComment:(NSString*)comment
    attachmentAsset:(ALAsset*)asset
           fileName:(NSString*)fileName
     attachmentType:(NSString*)type
     withCompletion:(void (^)(NSError * error))completion;

- (void)resendLocalComment:(IQComment*)comment withCompletion:(void (^)(NSError * error))completion;

- (void)deleteComment:(IQComment*)comment;

@end
