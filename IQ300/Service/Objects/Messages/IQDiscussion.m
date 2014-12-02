//
//  IQDiscussion.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQDiscussion.h"

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
                                                  @"short_name"       : @"createDate",
                                                  @"email"            : @"updateDate",
                                                  @"pusher_channel"   : @"pusherChannel"
                                                  }];
    return mapping;
}

@end
