//
//  FilterCounters.m
//  IQ300
//
//  Created by Tayphoon on 03.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "TaskFilterCounters.h"

@implementation CommunityFilter

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"community.id"    : @"communityId",
                                                  @"community.title" : @"title",
                                                  @"counter"         : @"count"
                                                  }];
    return mapping;
}


@end

@implementation TaskFilterCounters

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{ @"by_status" : @"statuses" }];
    
    RKRelationshipMapping * relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"by_community"
                                                                                   toKeyPath:@"communities"
                                                                                 withMapping:[CommunityFilter objectMapping]];
    [mapping addPropertyMapping:relation];

    return mapping;
}

@end
