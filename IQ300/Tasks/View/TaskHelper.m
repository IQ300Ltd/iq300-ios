//
//  TaskHelper.m
//  IQ300
//
//  Created by Tayphoon on 18.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskHelper.h"

@implementation TaskHelper

+ (UIColor*)colorForTaskType:(NSString*)type {
    static NSDictionary * _typeColors = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _typeColors = @{
                        @"new"       : [UIColor colorWithHexInt:0x00b54f],
                        @"on_init"   : [UIColor colorWithHexInt:0x9f9f9f],
                        @"browsed"   : [UIColor colorWithHexInt:0x753bb7],
                        @"in_work"   : [UIColor colorWithHexInt:0xf8931f],
                        @"refused"   : [UIColor colorWithHexInt:0xe74545],
                        @"completed" : IQ_CELADON_COLOR,
                        @"accepted"  : [UIColor colorWithHexInt:0x7dc223],
                        @"declined"  : [UIColor colorWithHexInt:0xe976ba],
                        @"archived"  : [UIColor colorWithHexInt:0x272727],
                        @"canceled"  : [UIColor colorWithHexInt:0x3b5b78]
                        };
    });
    
    if([_typeColors objectForKey:type]) {
        return [_typeColors objectForKey:type];
    }
    
    return [UIColor colorWithHexInt:0x9f9f9f];
}

+ (NSString*)displayNameForActionType:(NSString*)type {
    static NSDictionary * _actionDisplayNames = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _actionDisplayNames = @{
                                @"work"          : @"Agree",
                                @"refuse"        : @"Disagree",
                                @"complete"      : @"Complete",
                                @"accept"        : @"Accept",
                                @"decline"       : @"Return to work",
                                @"cancel"        : @"Cancel",
                                @"resend"        : @"Send to execute",
                                @"force_accept"  : @"Take as done"
                                };
    });
    
    if([_actionDisplayNames objectForKey:type]) {
        return [_actionDisplayNames objectForKey:type];
    }
    
    return nil;
}

+ (BOOL)isPositiveActionWithType:(NSString*)type {
    static NSArray * _positiveActionTypes = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _positiveActionTypes = @[@"work", @"complete", @"accept", @"resend"];
    });
    
    return [_positiveActionTypes containsObject:type];
}

@end
