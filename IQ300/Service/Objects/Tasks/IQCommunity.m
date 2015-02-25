//
//  IQCommunity.m
//  IQ300
//
//  Created by Tayphoon on 24.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQCommunity.h"

@implementation IQCommunity

@dynamic communityId;
@dynamic title;
@dynamic type;
@dynamic thumbUrl;
@dynamic mediumUrl;
@dynamic normalUrl;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"communityId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"              : @"communityId",
                                                  @"title"           : @"title",
                                                  @"type"            : @"type",
                                                  @"logo.thumb_url"  : @"thumbUrl",
                                                  @"logo.medium_url" : @"mediumUrl",
                                                  @"logo.normal_url" : @"normalUrl"
                                                  }];
    return mapping;
}

@end
