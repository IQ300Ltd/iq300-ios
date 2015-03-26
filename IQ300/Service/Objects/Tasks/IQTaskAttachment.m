//
//  IQTaskAttachment.m
//  IQ300
//
//  Created by Tayphoon on 26.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQTaskAttachment.h"

@implementation IQTaskAttachment

@dynamic taskId;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKObjectMapping * mapping = [super objectMappingForManagedObjectStore:store];
    [mapping addAttributeMappingsFromDictionary:@{ @"@parent.id" : @"taskId" }];
    
    return mapping;
}

@end
