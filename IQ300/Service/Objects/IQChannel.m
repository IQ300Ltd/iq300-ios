//
//  IQChannel.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 06/04/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQChannel.h"

@implementation IQChannel

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"data.channel"  : @"name",
                                                  }];
    return mapping;
}


@end
