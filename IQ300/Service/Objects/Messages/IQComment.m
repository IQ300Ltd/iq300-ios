//
//  IQComment.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQComment.h"

@implementation IQComment

@dynamic commentId;
@dynamic discussionId;
@dynamic createDate;
@dynamic body;
@dynamic author;
@dynamic attachments;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"commentId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"            : @"commentId",
                                                  @"discussion_id" : @"discussionId",
                                                  @"created_at"    : @"createDate",
                                                  @"body"          : @"body"
                                                  }];
    
    RKRelationshipMapping * relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"author"
                                                                                   toKeyPath:@"author"
                                                                                 withMapping:[IQUser objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"attachments"
                                                           toKeyPath:@"attachments"
                                                         withMapping:[IQAttachment objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];

    return mapping;
}

@end
