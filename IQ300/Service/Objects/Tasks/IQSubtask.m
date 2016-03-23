//
//  IQSubtask.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 23/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQSubtask.h"

#import <RestKit/RestKit.h>

#import "IQUser.h"
#import "IQManagedAttachment.h"
#import "IQProject.h"
#import "IQCommunity.h"
#import "IQManagedTodoItem.h"
#import "IQReconciliation.h"
#import "IQComplexity.h"

@implementation IQSubtask

@dynamic subtaskId;
@dynamic type;
@dynamic status;
@dynamic title;

@dynamic startDate;
@dynamic endDate;

@dynamic createdDate;
@dynamic updatedDate;

@dynamic parentId;

@dynamic customer;
@dynamic executor;
@dynamic community;
@dynamic project;

@dynamic hasAccess;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"subtaskId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"           : @"subtaskId",
                                                  @"kind"         : @"type",
                                                  @"status"       : @"status",
                                                  @"title"        : @"title",
                                                  @"start_date"   : @"startDate",
                                                  @"end_date"     : @"endDate",
                                                  @"created_at"   : @"createdDate",
                                                  @"updated_at"   : @"updatedDate",
                                                  @"parent_id"    : @"parentId",
                                                  @"has_access"   : @"hasAccess",
                                                  }];
    
    RKRelationshipMapping * relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"customer"
                                                                                   toKeyPath:@"customer"
                                                                                 withMapping:[IQUser objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"executor"
                                                           toKeyPath:@"executor"
                                                         withMapping:[IQUser objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"community"
                                                           toKeyPath:@"community"
                                                         withMapping:[IQCommunity objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"project"
                                                           toKeyPath:@"project"
                                                         withMapping:[IQProject objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    return mapping;
}

@end

