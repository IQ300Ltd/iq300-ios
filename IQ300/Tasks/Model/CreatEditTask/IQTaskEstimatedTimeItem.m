//
//  IQTaskEstimatedTimeItem.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTaskEstimatedTimeItem.h"
#import "IQTaskDataHolder.h"

@implementation IQTaskEstimatedTimeItem

- (instancetype)initWithTask:(id)task {
    NSAssert(task, @"Task expected");
    NSAssert([task respondsToSelector:@selector(estimatedTimeSeconds)], @"Task dont respond to estimated time selector");
    if ([super init]) {
        NSNumber *estimatedTime = [task estimatedTimeSeconds];
        
        NSUInteger seconds = estimatedTime.unsignedIntegerValue;
        
        NSUInteger hours = (NSUInteger)(seconds / 3600);
        NSUInteger minutes = (NSUInteger)(seconds - hours * 3600) / 60;
        
        _hours = (hours == 0 ? nil : [NSString stringWithFormat:(hours < 10 ? @"0%lu" : @"%lu"), (unsigned long)hours]);
        _minutes = ((hours == 0 && minutes == 0) ? nil : [NSString stringWithFormat:(minutes < 10 ? @"0%lu" : @"%lu"), (unsigned long)minutes]);
        _editable = YES;
    }
    return self;
}

- (void)setTask:(id)task {
    NSNumber *estimatedTime = [task estimatedTimeSeconds];
    
    NSUInteger seconds = estimatedTime.unsignedIntegerValue;
    
    NSUInteger hours = (NSUInteger)(seconds / 3600);
    NSUInteger minutes = (NSUInteger)(seconds - hours * 3600) / 60;
    
    _hours = (hours == 0 ? nil : [NSString stringWithFormat:(hours < 10 ? @"0%lu" : @"%lu"), (unsigned long)hours]);
    _minutes = ((hours == 0 && minutes == 0) ? nil : [NSString stringWithFormat:(minutes < 10 ? @"0%lu" : @"%lu"), (unsigned long)minutes]);

}

- (void)updateWithTask:(id)task value:(id)value {
    [task setEstimatedTimeSeconds:value];
    NSUInteger seconds = [value unsignedIntegerValue];
    
    NSUInteger hours = (NSUInteger)(seconds / 3600);
    NSUInteger minutes = (NSUInteger)(seconds - hours * 3600) / 60;
    
    _hours = (hours == 0 ? nil : [NSString stringWithFormat:(hours < 10 ? @"0%lu" : @"%lu"), (unsigned long)hours]);
    _minutes = ((hours == 0 && minutes == 0) ? nil : [NSString stringWithFormat:(minutes < 10 ? @"0%lu" : @"%lu"), (unsigned long)minutes]);

}

@end
