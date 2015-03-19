//
//  TaskController.h
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "TodoListModel.h"

@class IQTask;

@interface TInfoController : IQTableBaseController

@property (nonatomic, strong) TodoListModel * model;
@property (nonatomic, strong) IQTask * task;

@end
