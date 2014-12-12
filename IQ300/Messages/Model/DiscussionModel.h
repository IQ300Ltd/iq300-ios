//
//  DiscussionModel.h
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableModel.h"

@class IQDiscussion;
@class IQComment;
@class ALAsset;

@interface DiscussionModel : NSObject<IQTableModel>

@property (nonatomic, weak) IQDiscussion * discussion;
@property (nonatomic, strong) NSNumber * companionId;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, weak) id<IQTableModelDelegate> delegate;

- (id)initWithDiscussion:(IQDiscussion*)discussion;

- (void)reloadModelWithCompletion:(void (^)(NSError * error))completion;

- (void)reloadFirstPartWithCompletion:(void (^)(NSError * error))completion;

- (void)setSubscribedToSystemWakeNotifications:(BOOL)subscribed;

- (void)sendComment:(NSString*)comment
    attachmentAsset:(ALAsset*)asset
      attachmentIds:(NSArray*)attachmentIds
           fileName:(NSString*)fileName
     attachmentType:(NSString*)type
     withCompletion:(void (^)(NSError * error))completion;

- (void)deleteComment:(IQComment*)comment;

@end
