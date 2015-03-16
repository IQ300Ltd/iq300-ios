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
                                                  @"overdue" : @"overdue",
                                                  @"inbox"   : @"inbox",
                                                  @"outbox"  : @"outbox",
                                                  @"total"   : @"total"
                                                  }];
    return mapping;
}

@end
