//
//  IQTaskMember.m
//  IQ300
//
//  Created by Tayphoon on 23.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQTaskMember.h"
#import "IQUser.h"

@implementation IQTaskMember

@dynamic memberId;
@dynamic taskId;
@dynamic state;
@dynamic createdDate;
@dynamic updatedDate;
@dynamic taskRole;
@dynamic taskRoleName;
@dynamic communityRole;
@dynamic communityRoleName;
@dynamic user;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"memberId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"                                : @"memberId",
                                                  @"task_id"                           : @"taskId",
                                                  @"state"                             : @"state",
                                                  @"created_at"                        : @"createdDate",
                                                  @"updated_at"                        : @"updatedDate",
                                                  @"role_in_task.name"                 : @"taskRole",
                                                  @"role_in_task.translated_name"      : @"taskRoleName",
                                                  @"role_in_community.name"            : @"communityRole",
                                                  @"role_in_community.translated_name" : @"communityRoleName"
                                                  }];
    
    RKRelationshipMapping * relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"user"
                                                           toKeyPath:@"user"
                                                         withMapping:[IQUser objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    return mapping;
}
@end
