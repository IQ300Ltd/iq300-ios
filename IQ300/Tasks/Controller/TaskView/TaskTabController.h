//
//  TaskTabController.h
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTabBarController.h"

@class IQTask;
@class TaskPolicyInspector;

@interface TaskTabController : IQTabBarController

@property (nonatomic, strong) IQTask * task;
@property (nonatomic, strong) TaskPolicyInspector * policyInspector;

+ (void)taskTabControllerForTaskWithId:(NSNumber*)taskId completion:(void (^)(TaskTabController * controller, NSError * error))completion;

@end
