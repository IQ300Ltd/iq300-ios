//
//  TChangesCounter.m
//  IQ300
//
//  Created by Tayphoon on 23.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "TChangesCounter.h"

@implementation TChangesCounter

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"details"  : @"details",
                                                  @"comments" : @"comments",
                                                  @"users"    : @"users",
                                                  @"total"    : @"documents"
                                                  }];
    return mapping;
}

@end
