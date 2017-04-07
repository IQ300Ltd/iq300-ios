//
//  IQTaskPriorityItem.m
//  IQ300
//
//  Created by Viktor Shabanov on 4/7/17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "IQTaskPriorityItem.h"
#import "IQTask.h"
#import "TaskHelper.h"

@implementation IQTaskPriorityItem

- (instancetype)initWithTask:(id)task {
    NSAssert(task, @"Task expected");
    NSAssert([task respondsToSelector:@selector(priority)], @"Task dont respond to executors selector");
    
    NSString *text = [self textFromValue:[task performSelector:@selector(priority)]];
    self = [super initWithText:text];
    if (self) {
        self.accessoryImageName = @"right_gray_arrow.png";
    }
    return self;
}

- (void)setTask:(id)task {
    self.text = [self textFromValue:[task performSelector:@selector(priority)]];
}

- (void)updateWithTask:(id)task value:(id)value {
    [task performSelector:@selector(setPriority:) withObject:value];
    self.text = [self textFromValue:[task performSelector:@selector(priority)]];
}

- (NSString *)textFromValue:(id)value {
    NSString *text = [TaskHelper priorityNameForValue:value];
    return [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Importance", nil), text];
}

@end
