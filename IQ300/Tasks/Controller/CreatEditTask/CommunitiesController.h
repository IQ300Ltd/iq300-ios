//
//  CommunitiesController.h
//  IQ300
//
//  Created by Tayphoon on 15.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "CommunitiesModel.h"
#import "TaskFieldEditController.h"

@class IQCommunity;

@interface CommunitiesController : IQTableBaseController<TaskFieldEditController>

@property (nonatomic, strong) IQTaskDataHolder * task;
@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) CommunitiesModel * model;

@end
