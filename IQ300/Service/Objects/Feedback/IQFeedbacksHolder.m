//
//  IQFeedbacksHolder.m
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQFeedbacksHolder.h"

@implementation IQFeedbacksHolder

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKObjectMapping * mapping = [super objectMappingForManagedObjectStore:store];
    
    RKRelationshipMapping * tasksRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"error_reports"
                                                                                        toKeyPath:@"objects"
                                                                                      withMapping:[IQManagedFeedback objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:tasksRelation];
    return mapping;
}

@end
