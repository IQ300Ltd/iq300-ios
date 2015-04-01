//
//  TTodoItemsController.h
//  IQ300
//
//  Created by Tayphoon on 31.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTableBaseController.h"
#import "TodoListModel.h"

@interface TTodoItemsController : IQTableBaseController

@property (nonatomic, strong) TodoListModel * model;

@end
