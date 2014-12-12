//
//  IQConversation.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQConversation.h"

@implementation IQConversation

@dynamic conversationId;
@dynamic createDate;
@dynamic creatorId;
@dynamic type;
@dynamic unreadCommentsCount;
@dynamic totalCommentsCount;
@dynamic discussion;
@dynamic lastComment;
@dynamic users;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"conversationId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"                     : @"conversationId",
                                                  @"created_at"             : @"createDate",
                                                  @"creator_id"             : @"creatorId",
                                                  @"kind"                   : @"type",
                                                  @"newest_comments_count"  : @"unreadCommentsCount",
                                                  @"comments_count"         : @"totalCommentsCount"
                                                  }];
    
    RKRelationshipMapping * relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"discussion"
                                                                                   toKeyPath:@"discussion"
                                                                                 withMapping:[IQDiscussion objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"latest_comment"
                                                           toKeyPath:@"lastComment"
                                                         withMapping:[IQComment objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"discussion.users"
                                                           toKeyPath:@"users"
                                                         withMapping:[IQUser objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];

    return mapping;
}

@end
