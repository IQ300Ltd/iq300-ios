//
//  TaskExecutersController.h
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "TaskFieldEditController.h"
#import "TaskExecutorsModel.h"

@interface TaskExecutersController : IQTableBaseController<TaskFieldEditController>

@property (nonatomic, strong) IQTaskDataHolder * task;
@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) TaskExecutorsModel * model;

@end
