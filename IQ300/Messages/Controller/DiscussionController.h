//
//  DiscussionController.h
//  IQ300
//
//  Created by Tayphoon on 04.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "DiscussionModel.h"

@interface DiscussionController : IQTableBaseController

@property (nonatomic, strong) NSString * companionName;
@property (nonatomic, strong) DiscussionModel * model;

@end
