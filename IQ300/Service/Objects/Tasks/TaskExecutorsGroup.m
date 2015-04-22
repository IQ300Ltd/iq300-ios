//
//  TaskExecutorsGroup.m
//  IQ300
//
//  Created by Tayphoon on 20.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "TaskExecutorsGroup.h"
#import "TaskExecutor.h"

@implementation TaskExecutorsGroup


+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"group_name" : @"name"
                                                  }];
    
    RKRelationshipMapping * relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"users"
                                                                                   toKeyPath:@"executors"
                                                                                 withMapping:[TaskExecutor objectMapping]];
    [mapping addPropertyMapping:relation];
    
    return mapping;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[TaskExecutorsGroup class]]) {
        TaskExecutorsGroup * group = (TaskExecutorsGroup*)object;
        return [self.name isEqualToString:group.name];
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.name hash];
}

@end
