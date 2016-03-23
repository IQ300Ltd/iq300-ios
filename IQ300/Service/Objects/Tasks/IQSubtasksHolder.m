//
//  IQSubtasksHolder.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 23/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQSubtasksHolder.h"
#import "IQSubtask.h"

@implementation IQSubtasksHolder

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKObjectMapping * mapping = [super objectMappingForManagedObjectStore:store];
    
    RKRelationshipMapping * tasksRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"task_previews"
                                                                                        toKeyPath:@"objects"
                                                                                      withMapping:[IQSubtask objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:tasksRelation];
    return mapping;
}

@end
