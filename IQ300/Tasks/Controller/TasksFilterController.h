//
//  TasksFilterController.h
//  IQ300
//
//  Created by Tayphoon on 26.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TasksFilterModel.h"

@interface TasksFilterController : UIViewController <IQTableModelDelegate>

@property (nonatomic, strong) TasksFilterModel * model;

@end
