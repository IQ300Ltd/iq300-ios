//
//  IQNotification.m
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQNotification.h"

@implementation IQNotificable

@dynamic notificableId;
@dynamic type;
@dynamic title;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:@"IQNotificable" inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"notificableId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"    : @"notificableId",
                                                  @"type"  : @"type",
                                                  @"title" : @"title"
                                                  }];
    return mapping;
}

@end

@implementation IQNotification

@dynamic notificationId;
@dynamic readed;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic hasActions;
@dynamic notificable;
@dynamic mainDescription;
@dynamic additionalDescription;
@dynamic user;
@dynamic ownerId;
@dynamic availableActions;
@dynamic hasDiscussion;
@dynamic discussionId;
@dynamic commentId;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:@"IQNotification" inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"notificationId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                   @"id"                : @"notificationId",
                                                   @"readed"            : @"readed",
                                                   @"created_at"        : @"createdAt",
                                                   @"updated_at"        : @"updatedAt",
                                                   @"has_actions"       : @"hasActions",
                                                   @"main_text"         : @"mainDescription",
                                                   @"additional_text"   : @"additionalDescription",
                                                   @"recipient_id"      : @"ownerId",
                                                   @"available_actions" : @"availableActions",
                                                   @"has_discussion"    : @"hasDiscussion",
                                                   @"discussion_id"     : @"discussionId",
                                                   @"comment_id"        : @"commentId"
                                                   }];
    
    RKRelationshipMapping * notificableRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"notificable"
                                                                                              toKeyPath:@"notificable"
                                                                                            withMapping:[IQNotificable objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:notificableRelation];

    
    RKRelationshipMapping * userRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"user"
                                                                                      toKeyPath:@"user"
                                                                                    withMapping:[IQUser objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:userRelation];

    return mapping;
}

@end
