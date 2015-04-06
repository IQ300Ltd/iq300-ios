//
//  TaskActivitiesController.h
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "TaskTabItemController.h"
#import "TaskActivitiesModel.h"

@interface TaskActivitiesController : IQTableBaseController<TaskTabItemController>

@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, strong) NSNumber * badgeValue;
@property (nonatomic, strong) TaskActivitiesModel * model;
@property (nonatomic, weak) TaskPolicyInspector * policyInspector;

@end
