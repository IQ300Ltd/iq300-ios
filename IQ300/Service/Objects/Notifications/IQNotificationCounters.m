//
//  IQNotificationsCounter.m
//  IQ300
//
//  Created by Tayphoon on 03.02.16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQNotificationCounters.h"

@implementation IQNotificationCounters

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"pinned"             : @"pinnedCount",
                                                  @"not_pinned_unread"  : @"unreadCount"
                                                  }];
    return mapping;
}

@end
