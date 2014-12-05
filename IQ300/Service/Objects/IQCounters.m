//
//  NotificationsCount.m
//  IQ300
//
//  Created by Tayphoon on 26.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQCounters.h"

@implementation IQCounters

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"total"  : @"totalCount",
                                                  @"unread"   : @"unreadCount"
                                                 }];
    return mapping;
}

@end
