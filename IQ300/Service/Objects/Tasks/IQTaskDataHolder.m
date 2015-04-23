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

+ (RKObjectMapping*)requestObjectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"title"        : @"title",
                                                  @"community_id" : @"community.communityId",
                                                  @"executor_ids" : @"executorIds",
                                                  @"start_date"   : @"startDate",
                                                  @"end_date"     : @"endDate",
                                                  @"description"  : @"taskDescription"
                                                  }];
    
    return [mapping inverseMapping];
}

- (id)copyWithZone:(NSZone *)zone {
    IQTaskDataHolder * copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy.taskId = [self.taskId copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.community = self.community;
        copy.startDate = [self.startDate copyWithZone:zone];
        copy.endDate = [self.endDate copyWithZone:zone];
        copy.taskDescription = [self.taskDescription copyWithZone:zone];
        copy.executors = [self.executors copyWithZone:zone];
    }
    
    return copy;
}


- (NSArray*)executorIds {
    return [self.executors valueForKey:@"executorId"];
}

@end
