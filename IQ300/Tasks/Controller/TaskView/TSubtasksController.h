//
//  TSubtasksController.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 22/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "TaskTabItemController.h"

@class TaskSubtasksModel;
@class IQTask;

@interface TSubtasksController : IQTableBaseController<TaskTabItemController>

@property (nonatomic, strong) NSNumber * priveousTaskId;
@property (nonatomic, strong) IQTask * task;
@property (nonatomic, strong) TaskSubtasksModel * model;
@property (nonatomic, strong) NSNumber * badgeValue;
@property (nonatomic, weak) TaskPolicyInspector * policyInspector;

@end
