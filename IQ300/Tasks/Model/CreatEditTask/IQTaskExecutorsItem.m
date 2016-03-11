//
//  IQTaskExecutorsItem.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTaskExecutorsItem.h"
#import "IQTaskDataHolder.h"
#import "TaskExecutor.h"

@implementation IQTaskExecutorsItem

- (instancetype)initWithTask:(id)task {
    NSAssert(task, @"Task expected");
    NSAssert([task respondsToSelector:@selector(executors)], @"Task dont respond to executors selector");
    
    NSArray *executors = [task executors];
    
    NSString *text = nil;
    if (executors.count > 0) {
        NSString *titleTextPart = executors.count == 1 ? NSLocalizedString(@"Executor", nil) : NSLocalizedString(@"Executors", nil);
        id valueTextPart = executors.count == 1 ? [executors.firstObject executorName] : @(executors.count);
        text = [NSString stringWithFormat:@"%@: %@", titleTextPart, valueTextPart];
    }
    
    NSString *placeholder = NSLocalizedString(@"Executors", nil);
    
    self = [super initWithText:text placeholder:placeholder];
    if (self) {
        self.accessoryImageName = @"right_gray_arrow.png";
    }
    return self;
}

- (void)setTask:(id)task {
    NSArray *executors = [task executors];
    
    NSString *text = nil;
    if (executors.count > 0) {
        NSString *titleTextPart = executors.count == 1 ? NSLocalizedString(@"Executor", nil) : NSLocalizedString(@"Executors", nil);
        id valueTextPart = executors.count == 1 ? [executors.firstObject executorName] : @(executors.count);
        text = [NSString stringWithFormat:@"%@: %@", titleTextPart, valueTextPart];
    }
    self.text = text;
}

- (void)updateWithTask:(id)task value:(id)value {
    [task setExecutors:value];
    
    NSArray *executors = value;
    
    NSString *text = nil;
    if (executors.count > 0) {
        NSString *titleTextPart = executors.count == 1 ? NSLocalizedString(@"Executor", nil) : NSLocalizedString(@"Executors", nil);
        id valueTextPart = executors.count == 1 ? [executors.firstObject executorName] : @(executors.count);
        text = [NSString stringWithFormat:@"%@: %@", titleTextPart, valueTextPart];
    }
    self.text = text;
}



@end
