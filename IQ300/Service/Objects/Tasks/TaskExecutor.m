//
//  TaskExecutor.m
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "TaskExecutor.h"

@implementation TaskExecutor

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"   : @"executorId",
                                                  @"name" : @"executorName"
                                                  }];
    return mapping;
}

@end
