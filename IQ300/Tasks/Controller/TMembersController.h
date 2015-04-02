//
//  TMembersController.h
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "TaskMembersModel.h"
#import "TaskTabItemController.h"

@interface TMembersController : IQTableBaseController<TaskTabItemController>

@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, strong) TaskMembersModel * model;
@property (nonatomic, strong) NSNumber * badgeValue;
@property (nonatomic, weak) TaskPolicyInspector * policyInspector;

@end
