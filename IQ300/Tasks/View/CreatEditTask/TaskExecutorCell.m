//
//  TaskExecutorCell.m
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskExecutorCell.h"
#import "TaskExecutor.h"

@implementation TaskExecutorCell

@dynamic item;

- (void)setItem:(TaskExecutor *)item {
    [super setItem:item];
    
    self.titleTextView.text = item.executorName;
}

@end
