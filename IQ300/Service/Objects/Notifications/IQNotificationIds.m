//
//  IQNotificationIds.m
//  IQ300
//
//  Created by Tayphoon on 16.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQNotificationIds.h"

@implementation IQNotificationIds

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"notification_ids"   : @"notificationIds"
                                                  }];
    return mapping;
}

@end
