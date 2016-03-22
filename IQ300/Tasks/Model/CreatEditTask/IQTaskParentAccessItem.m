//
//  IQParentAccessItem.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 22/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTaskParentAccessItem.h"
#import "IQTaskDataHolder.h"

@implementation IQTaskParentAccessItem

@synthesize selected = _selected;

- (instancetype)initWithTask:(id)task {
    NSAssert(task, @"Task expected");
    NSAssert([task respondsToSelector:@selector(parentTaskAccess)], @"Task dont respond to title selector");
    
    NSString *title = NSLocalizedString(@"Access to parent", nil);
    
    self = [super initWithText:title];
    if (self) {
        [self setTask:task];
    }
    return self;
}

- (void)setTask:(id)task {
    NSNumber *parentTaskAccess = [task parentTaskAccess];
    if (parentTaskAccess && parentTaskAccess.boolValue) {
        self.accessoryImageName = @"gray_checked_checkbox.png";
        _selected = YES;
    }
    else {
        self.accessoryImageName = @"gray_checkbox.png";
        _selected = NO;
    }
}

- (void)updateWithTask:(id)task value:(id)value {
    [task setParentTaskAccess:value];
    [self setTask:task];
}

- (BOOL)selected {
    return _selected;
}

@end
