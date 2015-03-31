//
//  TaskPolicies.m
//  IQ300
//
//  Created by Tayphoon on 25.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "TaskPolicies.h"

@implementation TaskPolicies

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"main_actions"   : @"details",
                                                  @"status_actions" : @"status",
                                                  @"todo_items"     : @"todoItems",
                                                  @"comments"       : @"comments",
                                                  @"attachments"    : @"documents",
                                                  @"users"          : @"users",
                                                  @"activities"     : @"activities"
                                                  }];
    return mapping;
}

@end
