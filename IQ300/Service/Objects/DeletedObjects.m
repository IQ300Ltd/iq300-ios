//
//  DeletedObjects.m
//  IQ300
//
//  Created by Tayphoon on 24.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "DeletedObjects.h"

@implementation DeletedObjects

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"deleted_comment_ids" : @"objectIds",
                                                  @"current_date"        : @"serverDate"
                                                  }];
    return mapping;
}

@end
