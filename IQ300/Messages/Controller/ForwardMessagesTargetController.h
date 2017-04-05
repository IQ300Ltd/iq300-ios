//
//  ForwardMessagesTargetController.h
//  IQ300
//
//  Created by Viktor Sabanov on 05.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "MessagesController.h"

@class IQComment;

@interface ForwardMessagesTargetController : MessagesController

@property (nonatomic, strong) IQComment *forwardingComment;

@end
