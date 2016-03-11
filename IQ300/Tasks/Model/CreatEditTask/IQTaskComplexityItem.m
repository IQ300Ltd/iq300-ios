//
//  IQTaskComplexityItem.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTaskComplexityItem.h"
#import "IQTask.h"
#import "IQComplexity.h"

@implementation IQTaskComplexityItem

- (instancetype)initWithTask:(id)task {
    NSAssert(task, @"Task expected");
    NSAssert([task respondsToSelector:@selector(complexity)], @"Task dont respond to executors selector");
    
    IQComplexity *complexity = [task complexity];
    NSString *text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Complexity", nil),
                                                           (complexity ? complexity.displayName : NSLocalizedString(@"Normal", nil))];
    self = [super initWithText:text];
    if (self) {
        self.accessoryImageName = @"right_gray_arrow.png";
    }
    return self;
}

- (void)setTask:(id)task {
    IQComplexity *complexity = [task complexity];
    NSString *text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Complexity", nil),
                      (complexity ? complexity.displayName : NSLocalizedString(@"Normal", nil))];
    self.text = text;
}

- (void)updateWithTask:(id)task value:(id)value {
    [task setComplexity:value];
    
    IQComplexity *complexity = value;
    NSString *text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Complexity", nil),
                      (complexity ? complexity.displayName : NSLocalizedString(@"Normal", nil))];
    self.text = text;
    
}

@end
