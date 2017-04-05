//
//  ForwardMessagesTargetController.h
//  IQ300
//
//  Created by Viktor Shabanov on 05.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "MessagesController.h"

@class IQComment;

@interface ForwardMessagesTargetController : MessagesController

@property (nonatomic, strong) IQComment *forwardingComment;

- (NSArray *)showableViewControllersStackFromCurrentStack:(NSArray *)currentStack
                                  forTargetViewController:(UIViewController *)viewController;

@end
