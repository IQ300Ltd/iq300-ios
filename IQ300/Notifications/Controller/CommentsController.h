//
//  DiscussionViewController.h
//  IQ300
//
//  Created by Tayphoon on 24.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "CommentsModel.h"

@interface CommentsController : IQTableBaseController

@property (nonatomic, strong) NSString * subTitle;
@property (nonatomic, strong) CommentsModel * model;

@end
