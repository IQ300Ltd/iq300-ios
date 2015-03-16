//
//  IQGroupCounter.m
//  IQ300
//
//  Created by Tayphoon on 13.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQGroupCounter.h"

@implementation IQGroupCounter

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"sid"          : @"sID",
                                                  @"unread_count" : @"unreadCount"
                                                  }];
    return mapping;
}

@end
