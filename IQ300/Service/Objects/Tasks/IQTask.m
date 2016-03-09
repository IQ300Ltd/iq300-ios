//
//  IQTask.m
//  IQ300
//
//  Created by Tayphoon on 20.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQTask.h"
#import "IQUser.h"
#import "IQManagedAttachment.h"
#import "IQProject.h"
#import "IQCommunity.h"
#import "IQManagedTodoItem.h"
#import "IQReconciliation.h"
#import "IQComplexity.h"

@implementation IQTask

@dynamic taskId;
@dynamic type;
@dynamic recipientId;
@dynamic ownerId;
@dynamic ownerType;
@dynamic status;
@dynamic title;
@dynamic taskDescription;
@dynamic startDate;
@dynamic endDate;
@dynamic createdDate;
@dynamic updatedDate;
@dynamic templateId;
@dynamic parentId;
@dynamic duration;
@dynamic position;
@dynamic discussionId;
@dynamic commentsCount;
@dynamic availableActions;
@dynamic availableFeatures;
@dynamic complexity;
@dynamic estimatedTime;

@dynamic customer;
@dynamic executor;
@dynamic community;
@dynamic project;

@dynamic childIds;
@dynamic todoItems;
@dynamic attachments;

@dynamic reconciliation;
@dynamic reconciliationState;
@dynamic reconciliationActions;

@dynamic reconciliationActionsCount;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"taskId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"                       : @"taskId",
                                                  @"kind"                     : @"type",
                                                  @"recipient_id"             : @"recipientId",
                                                  @"owner.id"                 : @"ownerId",
                                                  @"owner.type"               : @"ownerType",
                                                  @"status"                   : @"status",
                                                  @"title"                    : @"title",
                                                  @"description"              : @"taskDescription",
                                                  @"start_date"               : @"startDate",
                                                  @"end_date"                 : @"endDate",
                                                  @"created_at"               : @"createdDate",
                                                  @"updated_at"               : @"updatedDate",
                                                  @"template_id"              : @"templateId",
                                                  @"parent_id"                : @"parentId",
                                                  @"duration"                 : @"duration",
                                                  @"position"                 : @"position",
                                                  @"discussion_id"            : @"discussionId",
                                                  @"child_ids"                : @"childIds",
                                                  @"comments_count"           : @"commentsCount",
                                                  @"available_status_actions" : @"availableActions",
                                                  @"reconciliation_state"     : @"reconciliationState",
                                                  @"reconciliation_actions"   : @"reconciliationActions",
                                                  @"estimated_time"           : @"estimatedTime",
                                                  @"available_features"       : @"availableFeatures",
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
    
    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"todo_items"
                                                           toKeyPath:@"todoItems"
                                                         withMapping:[IQManagedTodoItem objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];

    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"attachments"
                                                           toKeyPath:@"attachments"
                                                         withMapping:[IQManagedAttachment objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"reconciliation_decisions_stat"
                                                           toKeyPath:@"reconciliation"
                                                         withMapping:[IQReconciliation objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"complexity"
                                                           toKeyPath:@"complexity"
                                                         withMapping:[IQComplexity objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    return mapping;
}

- (void)addAttachmentsObject:(NSManagedObject *)value{
    [self willChangeValueForKey:@"attachments"];
    NSMutableOrderedSet *tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.attachments];
    [tempSet addObject: value];
    self.attachments = tempSet;
    [self didChangeValueForKey:@"attachments"];
}

- (void)setReconciliationActions:(NSOrderedSet *)reconciliationActions {
    [self willChangeValueForKey:@"reconciliationActions"];
    [self setPrimitiveValue:reconciliationActions forKey:@"reconciliationActions"];
    self.reconciliationActionsCount = @([reconciliationActions count]);
    [self didChangeValueForKey:@"reconciliationActions"];
}

@end
