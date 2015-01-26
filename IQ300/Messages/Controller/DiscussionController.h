//
//  DiscussionController.h
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "DiscussionModel.h"

@class IQConversation;

@interface DiscussionController : IQTableBaseController

@property (nonatomic, strong) DiscussionModel * model;

@end
