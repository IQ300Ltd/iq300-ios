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
@dynamic discussion;
@dynamic lastComment;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"conversationId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"               : @"conversationId",
                                                  @"short_name"       : @"createDate",
                                                  @"email"            : @"creatorId",
                                                  @"pusher_channel"   : @"type"
                                                  }];
    return mapping;
}

@end
