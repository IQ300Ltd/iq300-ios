//
//  IQFeedbackCategory.m
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQFeedbackCategory.h"

@implementation IQFeedbackCategory

@dynamic categoryId;
@dynamic title;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class])
                                                    inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"categoryId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"    : @"categoryId",
                                                  @"title" : @"title"
                                                  }];
    return mapping;
}

@end
