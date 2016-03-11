//
//  IQTaskDescriptionItem.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTaskDescriptionItem.h"
#import "IQTaskDataHolder.h"

@implementation IQTaskDescriptionItem

- (instancetype)initWithTask:(id)task {
    NSAssert(task, @"Task expected");
    NSAssert([task respondsToSelector:@selector(taskDescription)], @"Task dont respond to taskDescription selector");
    
    NSString *description = [task taskDescription];
    NSString *placeholder = NSLocalizedString(@"Description", nil);
    
    self = [super initWithText:description placeholder:placeholder];
    if (self) {
#ifdef IPAD
        self.editable = YES;
        self.returnKeyType = UIReturnKeyDefault;
#else
        self.accessoryImageName = @"right_gray_arrow.png";
#endif
    }
    return self;
}

- (void)setTask:(id)task {
    NSString *description = [task taskDescription];
    self.text = description;
}

- (void)updateWithTask:(id)task value:(id)value {
    NSAssert(task, @"Task expected");
    NSAssert([task respondsToSelector:@selector(setTaskDescription:)], @"Task dont respond to setTaskDescription selector");
    NSAssert([value isKindOfClass:[NSString class]], @"Task description should be string");
    
    [task setTaskDescription:value];
    self.text = value;
}

@end
