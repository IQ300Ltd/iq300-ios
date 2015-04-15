//
//  IQCommunityInfo.m
//  IQ300
//
//  Created by Tayphoon on 15.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQCommunityInfo.h"

@implementation IQCommunityInfo

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"         : @"communityId",
                                                  @"title"      : @"title",
                                                  @"sort_order" : @"sortOrder"
                                                  }];
    return mapping;
}

@end
