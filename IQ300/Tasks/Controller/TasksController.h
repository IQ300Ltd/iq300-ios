//
//  ViewController.h
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "TasksModel.h"

@interface TasksController : IQTableBaseController

@property (nonatomic, strong) TasksModel * model;

- (void)updateGlobalCounter;

@end

