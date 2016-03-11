//
//  IQTaskTitleItem.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 09/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTaskTitleItem.h"

@implementation IQTaskTitleItem

- (instancetype)initWithTask:(id)task {
    NSAssert(task, @"Task expected");
    NSAssert([task respondsToSelector:@selector(title)], @"Task dont respond to title selector");

    NSString *title = [task title];
    NSString *placeholder = NSLocalizedString(@"Title", nil);
    
    self = [super initWithText:title placeholder:placeholder editable:YES];
    if (self) {
        
    }
    return self;
}

- (void)setTask:(id)task {
    NSString *title = [task title];
    self.text = title;
}

- (void)updateWithTask:(id)task value:(id)value {
    NSAssert(task, @"Task expected");
    NSAssert([task respondsToSelector:@selector(setTitle:)], @"Task dont respond to setTitle selector");
    NSAssert([value isKindOfClass:[NSString class]], @"Title should be string");
    
    [task setTitle:value];
    self.text = value;
}

@end
