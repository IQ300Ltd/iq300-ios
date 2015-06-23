//
//  NSObject+PerformSelector.m
//  OBI
//
//  Created by Tayphoon on 22.05.13.
//  Copyright (c) 2013 Tayphoon. All rights reserved.
//

#import "NSObject+PerformSelector.h"
#import <objc/message.h>

@implementation NSObject (PerformSelector)

- (void)performSelector:(SEL)selector withObjects:(id)firstObj, ... {
    va_list args;
    va_start(args, firstObj);
    ((void(*)(id, SEL, ...))objc_msgSend)(self, selector, args);
    va_end(args);
}

- (void)performSelector:(SEL)selector afterDelay:(NSTimeInterval)delay withObjects:(id)firstObj, ... {
    va_list args;
    va_start(args, firstObj);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        ((void(*)(id, SEL, ...))objc_msgSend)(self, selector, args);
    });
    va_end(args);
}

@end
