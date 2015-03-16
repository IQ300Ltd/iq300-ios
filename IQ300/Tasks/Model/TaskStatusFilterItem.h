//
//  TaskStatusFilterItem.h
//  IQ300
//
//  Created by Tayphoon on 04.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskFilterItem.h"

@interface TaskStatusFilterItem : NSObject<TaskFilterItem>

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSNumber * count;

@end
