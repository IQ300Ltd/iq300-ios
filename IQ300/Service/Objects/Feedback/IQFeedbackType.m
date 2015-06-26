//
//  IQFeedbackType.m
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQFeedbackType.h"

@implementation IQFeedbackType

@dynamic typeId;
@dynamic type;
@dynamic localizedTitle;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class])
                                                    inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"typeId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"               : @"typeId",
                                                  @"title"            : @"type",
                                                  @"translated_title" : @"localizedTitle"
                                                  }];
    return mapping;
}

@end
