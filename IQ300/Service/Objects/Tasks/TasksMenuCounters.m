//
//  TasksMenuCounters.m
//  IQ300
//
//  Created by Tayphoon on 03.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "TasksMenuCounters.h"

@implementation TasksMenuCounters

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"menu_counters.overdue"      : @"overdue",
                                                  @"menu_counters.new"          : @"inboxNew",
                                                  @"menu_counters.browsed"      : @"inboxBrowsed",
                                                  @"menu_counters.completed"    : @"outboxCompleted",
                                                  @"menu_counters.refused"      : @"outboxRefused",
                                                  @"menu_counters.total"        : @"total",
                                                  @"menu_counters.not_approved" : @"notApproved"
                                                  }];
    return mapping;
}

@end
