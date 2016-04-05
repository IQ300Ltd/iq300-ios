//
//  TaskExecutorCell.h
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQSelectableTextCell.h"

@class TaskExecutor;
@class IQOnlineIndicator;

@interface TaskExecutorCell : IQSelectableTextCell

@property (nonatomic, strong) TaskExecutor * item;
@property (nonatomic, strong) IQOnlineIndicator *onlineIndicator;


@end
