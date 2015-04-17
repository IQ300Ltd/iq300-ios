//
//  IQTaskDataHolder.m
//  IQ300
//
//  Created by Tayphoon on 16.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQTaskDataHolder.h"
#import "IQTask.h"
#import "IQCommunity.h"

@implementation IQTaskDataHolder

+ (IQTaskDataHolder*)holderWithTask:(IQTask *)task {
    IQTaskDataHolder * holder = [[IQTaskDataHolder alloc] init];
    holder.taskId = task.taskId;
    holder.title = task.title;
    holder.community = task.community;
    holder.startDate = task.startDate;
    holder.endDate = task.endDate;
    holder.taskDescription = task.taskDescription;
    
    if (task.executor) {
        holder.executors = @[task.executor];
    }
    
    return holder;
}

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"title"        : @"title",
                                                  @"community_id" : @"community.communityId",
                                                  @"executors"    : @"executors",
                                                  @"start_date"   : @"startDate",
                                                  @"end_date"     : @"endDate",
                                                  @"description"  : @"taskDescription"
                                                  }];
    return mapping;
}

+ (RKObjectMapping*)requestObjectMapping {
    RKObjectMapping * objectMapping = [self objectMapping];
    
    return [objectMapping inverseMapping];
}

@end
