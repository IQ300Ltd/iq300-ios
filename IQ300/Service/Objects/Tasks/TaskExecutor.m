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
                                                  @"id"     : @"executorId",
                                                  @"name"   : @"executorName",
                                                  @"online" : @"online",
                                                  }];
    return mapping;
}

- (id)copyWithZone:(NSZone *)zone {
    TaskExecutor * copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy.executorId = [self.executorId copyWithZone:zone];
        copy.executorName = [self.executorName copyWithZone:zone];
    }
    
    return copy;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[TaskExecutor class]]) {
        TaskExecutor * executer = (TaskExecutor*)object;
        return [self.executorId isEqualToNumber:executer.executorId];
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.executorId hash];
}

@end
