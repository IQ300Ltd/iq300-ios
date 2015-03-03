//
//  TaskFilterSortItem.h
//  IQ300
//
//  Created by Tayphoon on 27.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskFilterItem.h"

@interface TaskFilterSortItem : NSObject<TaskFilterItem>

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * sortField;

@end
