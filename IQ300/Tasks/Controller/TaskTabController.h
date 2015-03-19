//
//  TaskTabController.h
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTabBarController.h"

@class IQTask;

@interface TaskTabController : IQTabBarController

@property (nonatomic, strong) IQTask * task;

@end
