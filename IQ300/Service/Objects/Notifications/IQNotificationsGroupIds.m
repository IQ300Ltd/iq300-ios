//
//  IQNotificationsGroupIds.m
//  IQ300
//
//  Created by Tayphoon on 18.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQNotificationsGroupIds.h"

@implementation IQNotificationsGroupIds

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"group_sids"   : @"groupIds"
                                                  }];
    return mapping;
}

@end
