//
//  IQDiscussion.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQDiscussion.h"
#import "IQUser.h"
#import "CViewInfo.h"

@implementation IQDiscussion

@dynamic discussionId;
@dynamic createDate;
@dynamic updateDate;
@dynamic pusherChannel;
@dynamic users;
@dynamic userViews;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"discussionId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"               : @"discussionId",
                                                  @"created_at"       : @"createDate",
                                                  @"updated_at"       : @"updateDate",
                                                  @"pusher_channel"   : @"pusherChannel"
                                                  }];
    
    RKRelationshipMapping * relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"users"
                                                                                   toKeyPath:@"users"
                                                                                 withMapping:[IQUser objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"user_views"
                                                           toKeyPath:@"userViews"
                                                         withMapping:[CViewInfo objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];


    return mapping;
}

@end
