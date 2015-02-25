//
//  IQTasksHolder.m
//  IQ300
//
//  Created by Tayphoon on 24.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQTasksHolder.h"

@implementation IQTasksHolder

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKObjectMapping * mapping = [super objectMappingForManagedObjectStore:store];
    
    RKRelationshipMapping * tasksRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"tasks"
                                                                                                toKeyPath:@"objects"
                                                                                              withMapping:[IQTask objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:tasksRelation];
    return mapping;
}

@end
