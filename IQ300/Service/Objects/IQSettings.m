//
//  IQSettings.m
//  IQ300
//
//  Created by Viktor Sabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "IQSettings.h"
#import <RestKit/RestKit.h>

@implementation IQSettings

+ (RKObjectMapping *)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"pushEnabled"  : @"notifications.push_enabled"
                                                  }];
    return mapping;
}

@end
