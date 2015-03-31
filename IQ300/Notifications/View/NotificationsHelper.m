//
//  NotificationsHelper.m
//  IQ300
//
//  Created by Tayphoon on 02.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "NotificationsHelper.h"

@implementation NotificationsHelper

+ (NSString*)displayNameForActionType:(NSString*)type {
    static NSDictionary * _actionDisplayNames = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _actionDisplayNames = @{
                                @"refuse"                 : @"Refuse",
                                @"accept"                 : @"Accept",
                                @"decline"                : @"Refuse",
                                @"refuse"                 : @"Refuse",
                                
                                @"basetask_browse"        : @"Accept",
                                @"basetask_accept"        : @"Accept",
                                @"basetask_refuse"        : @"Refuse",
                                @"basetask_decline"       : @"To refine",
                                @"basetask_work"          : @"To work",
                                
                                @"basecommunity_accept"   : @"Accept",
                                @"basecommunity_decline"  : @"Refuse",
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
        _positiveActionTypes = @[@"accept", @"browse", @"work", @"complete"];
    });
    
    return [_positiveActionTypes containsObject:type];
}

@end
