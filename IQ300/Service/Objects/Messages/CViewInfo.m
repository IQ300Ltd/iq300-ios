//
//  CViewInfo.m
//  IQ300
//
//  Created by Tayphoon on 11.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "CViewInfo.h"

@implementation CViewInfo

@dynamic userId;
@dynamic discussionId;
@dynamic viewDate;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"userId", @"discussionId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"user_id"    : @"userId",
                                                  @"@parent.id" : @"discussionId",
                                                  @"viewed_at"  : @"viewDate"
                                                  }];
    return mapping;
}

@end
