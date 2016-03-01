//
//  TaskComplexityController.h
//  IQ300
//
//  Created by Vladislav Grigoryev on 29/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "TaskFieldEditController.h"
#import "TaskComplexityModel.h"

@class IQComplexity;

@interface TaskComplexityController : IQTableBaseController <TaskFieldEditController>

@property (nonatomic, strong) NSIndexPath * fieldIndexPath;
@property (nonatomic, strong) IQComplexity * fieldValue;
@property (nonatomic, strong) IQTaskDataHolder * task;
@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) TaskComplexityModel *model;

@end
