//
//  IQTaskDeletedIds.m
//  IQ300
//
//  Created by Tayphoon on 03.08.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQTaskDeletedIds.h"

@implementation IQTaskDeletedIds

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"deleted_task_ids" : @"objectIds",
                                                  @"current_date"     : @"serverDate"
                                                  }];
    return mapping;
}

@end
