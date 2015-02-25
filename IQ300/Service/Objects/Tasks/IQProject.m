//
//  IQProject.m
//  IQ300
//
//  Created by Tayphoon on 24.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQProject.h"

@implementation IQProject

@dynamic projectId;
@dynamic title;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"projectId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"    : @"projectId",
                                                  @"title" : @"title"
                                                 }];
    return mapping;
}

@end
