//
//  ForwardMessagesTargetController.h
//  IQ300
//
//  Created by Viktor Sabanov on 05.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "MessagesController.h"

@class IQComment;
@class DiscussionModel;

@protocol ForwardMessagesTargetControllerDelegate <NSObject>

- (void)reloadDialogControllerWithModel:(DiscussionModel *)model withTitle:(NSString *)title;

@end

@interface ForwardMessagesTargetController : MessagesController

@property (nonatomic, strong) IQComment *forwardingComment;
@property (nonatomic, weak) id<ForwardMessagesTargetControllerDelegate> delegate;

@end
