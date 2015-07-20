//
//  IQConversation.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQConversation.h"

#import "IQService.h"
#import "NSManagedObject+ActiveRecord.h"
#import "NSManagedObjectContext+AsyncFetch.h"

@implementation IQConversation

@dynamic conversationId;
@dynamic title;
@dynamic ownerId;
@dynamic createDate;
@dynamic creatorId;
@dynamic adminId;
@dynamic type;
@dynamic unreadCommentsCount;
@dynamic totalCommentsCount;
@dynamic discussion;
@dynamic lastComment;
@dynamic users;
@dynamic removed;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"conversationId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"                     : @"conversationId",
                                                  @"title"                  : @"title",
                                                  @"recipient_id"           : @"ownerId",
                                                  @"created_at"             : @"createDate",
                                                  @"creator_id"             : @"creatorId",
                                                  @"admin_id"               : @"adminId",
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

+ (void)clearRemovedConversationsInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQConversation"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"removed == %@", @(YES)]];
    
    [context executeFetchRequest:fetchRequest completion:^(NSArray *objects, NSError *error) {
        for (IQConversation *object in objects) {
            [object removeLocalConversationInContext:context];
        }
    }];
}

+ (void)removeLocalConversationWithId:(NSNumber *)conversationId context:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"conversationId == %@", conversationId];
    
    IQConversation *conversation = [IQConversation findFirstWithPredicate:predicate inContext:context];
    [conversation removeLocalConversationInContext:context];
}

- (void)removeLocalConversationInContext:(NSManagedObjectContext *)context {
    [context deleteObject:self];
    [context deleteObject:self.discussion];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IQComment"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"discussionId == %@", self.discussion.discussionId]];
    [context executeFetchRequest:fetchRequest completion:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            for (NSManagedObject * object in objects) {
                [context deleteObject:object];
            }
            
            NSError * saveError = nil;
            if(![context saveToPersistentStore:&saveError] ) {
                NSLog(@"Failed save to presistent store after comments removed");
            }
        }
    }];
}

@end
