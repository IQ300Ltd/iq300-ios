//
//  IQTaskHistoryItem.m
//  IQ300
//
//  Created by Tayphoon on 02.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQTaskHistoryItem.h"

@implementation IQTaskHistoryItem

@dynamic itemId;
@dynamic createdDate;
@dynamic title;
@dynamic ownerId;
@dynamic mainDescription;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"itemId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"         : @"itemId",
                                                  @"title"      : @"title",
                                                  @"descr"      : @"mainDescription",
                                                  @"updated_at" : @"updatedDate"
                                                  }];
    return mapping;
}

@end
