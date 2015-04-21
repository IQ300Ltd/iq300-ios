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
    RKRelationshipMapping * relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"users"
                                                                                   toKeyPath:@"users"
                                                                                 withMapping:[TaskExecutor objectMapping]];
    [mapping addPropertyMapping:relation];
    
    return mapping;
}

@end
