//
//  TasksFilterController.h
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TasksFilterModel.h"

@class TasksFilterController;

@protocol TasksFilterControllerDelegate <NSObject>

@optional
- (void)filterControllerWillFinish:(TasksFilterController*)controller;

@end

@interface TasksFilterController : UIViewController <IQTableModelDelegate>

@property (nonatomic, strong) TasksFilterModel * model;
@property (nonatomic, weak) id<TasksFilterControllerDelegate> delegate;

@end
