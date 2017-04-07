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
#import "IQUser.h"
#import "TaskExecutor.h"

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
        TaskExecutor * executor = [[TaskExecutor alloc] init];
        executor.executorId = task.executor.userId;
        executor.executorName = task.executor.displayName;
        holder.executors = @[executor];
    }
    
    holder.estimatedTimeSeconds = task.estimatedTime;
    holder.priority = task.priority;
    holder.parentTaskAccess = task.parentTaskAccessRestriction;
    holder.parentTaskId = task.parentId;
    
    holder.parentStartDate = task.parentStartDate;
    holder.parentEndDate = task.parentEndDate;
    
    return holder;
}

+ (RKObjectMapping*)createRequestObjectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"title"                                    : @"title",
                                                  @"community_id"                             : @"community.communityId",
                                                  @"executor_ids"                             : @"executorIds",
                                                  @"start_date"                               : @"startDate",
                                                  @"end_date"                                 : @"endDate",
                                                  @"description"                              : @"taskDescription",
                                                  @"estimated_time"                           : @"estimatedTimeSeconds",
                                                  @"parent_id"                                : @"parentTaskId",
                                                  @"executor_restrictions.parent_task_access" : @"parentTaskAccess",
                                                  @"priority"                                 : @"priority"
                                                  }];
    
    return [mapping inverseMapping];
}

+ (RKObjectMapping*)editRequestObjectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"title"          : @"title",
                                                  @"executor_id"    : @"firstExecutorId",
                                                  @"start_date"     : @"startDate",
                                                  @"end_date"       : @"endDate",
                                                  @"description"    : @"taskDescription",
                                                  @"estimated_time" : @"estimatedTimeSeconds",
                                                  @"executor_restrictions.parent_task_access" : @"parentTaskAccess",
                                                  @"priority"       : @"priority"
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
        copy.estimatedTimeSeconds = [self.estimatedTimeSeconds copyWithZone:zone];
        copy.priority = self.priority;
        copy.parentTaskId = self.parentTaskId;
        copy.parentTaskAccess = self.parentTaskAccess;
        copy.parentEndDate = self.parentEndDate;
        copy.parentStartDate = self.parentStartDate;
    }
    
    return copy;
}

- (void)setParentTask:(IQTask *)parentTask {
    _parentTaskId = parentTask.taskId;
    if (_parentTaskId) {
        _startDate = parentTask.startDate;
        _endDate = parentTask.endDate;
        _parentStartDate = parentTask.parentStartDate;
        _parentEndDate = parentTask.parentEndDate;
    }
}

- (NSArray*)executorIds {
    return [self.executors valueForKey:@"executorId"];
}

- (NSNumber*)firstExecutorId {
    return [self.executors.firstObject valueForKey:@"executorId"];
}


@end


//+ (NSNumber *)secondsFromTimeString:(NSString *)dateString {
//    NSString *trimmedString = [dateString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//
//    NSError *error = nil;
//    NSRegularExpression *dotCommaRegexp = [NSRegularExpression regularExpressionWithPattern:@"\\d+((\\.|,)(\\d)*)?" options:0 error:&error];
//    if (error) {
//        NSLog(@"Regexp error: %@", error.description);
//        return nil;
//    }
//    NSTextCheckingResult *match = [dotCommaRegexp firstMatchInString:trimmedString options:0 range:NSMakeRange(0, trimmedString.length)];
//    if (match) {
//        CGFloat hours = trimmedString.floatValue;
//        NSNumber *seconds = @((NSInteger)(hours * SECONDS_IN_HOUR));
//        return seconds;
//    }
//
//    NSRegularExpression *colonRegexp = [NSRegularExpression regularExpressionWithPattern:@"\\d+(:(\\d)*){1,2}" options:0 error:&error];
//    if (error) {
//        NSLog(@"Regexp error: %@", error.description);
//        return nil;
//    }
//    match = [colonRegexp firstMatchInString:trimmedString options:0 range:NSMakeRange(0, trimmedString.length)];
//    if (match) {
//        NSArray *components = [trimmedString componentsSeparatedByString:@":"];
//        NSUInteger seconds = 0;
//        NSUInteger componentWeight = SECONDS_IN_HOUR;
//        for (NSString *component in components) {
//            if (component.length > 0) {
//                seconds += componentWeight * component.integerValue;
//            }
//            componentWeight /= 60;
//        }
//        return @(seconds);
//    }
//
//    return nil;
//}
