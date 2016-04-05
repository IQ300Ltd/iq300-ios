//
//  IQConversationMember.m
//  IQ300
//
//  Created by Tayphoon on 13.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQConversationMember.h"
#import "IQUser.h"

@implementation IQConversationMember

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"                  : @"userId",
                                                  @"short_name"          : @"displayName",
                                                  @"mention_name"        : @"nickName",
                                                  @"email"               : @"email",
                                                  @"photo.thumb_url"     : @"thumbUrl",
                                                  @"photo.medium_url"    : @"mediumUrl",
                                                  @"photo.normal_url"    : @"normalUrl",
                                                  @"is_conference_admin" : @"isAdministrator",
                                                  @"online"              : @"online",
                                                  }];

    return mapping;
}

+ (IQConversationMember*)meberFromUser:(IQUser*)user {
    IQConversationMember * memeber = [[IQConversationMember alloc] init];
    memeber.userId = user.userId;
    memeber.displayName = user.displayName;
    memeber.nickName = user.nickName;
    memeber.email = user.email;
    memeber.thumbUrl = user.thumbUrl;
    memeber.mediumUrl = user.mediumUrl;
    memeber.normalUrl = user.normalUrl;
    memeber.online = user.online;
    return memeber;
}

@end
