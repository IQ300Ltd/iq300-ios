//
//  TaskController.h
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "TodoListModel.h"
#import "TaskTabItemController.h"

@class IQTask;

@interface TInfoController : IQTableBaseController<TaskTabItemController>

@property (nonatomic, strong) TodoListModel * model;
@property (nonatomic, strong) IQTask * task;
@property (nonatomic, strong) NSNumber * badgeValue;
@property (nonatomic, weak) TaskPolicyInspector * policyInspector;

@end
