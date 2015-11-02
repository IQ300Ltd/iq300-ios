//
//  IQContactsDeletedIds.m
//  IQ300
//
//  Created by Tayphoon on 28.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "IQContactsDeletedIds.h"

@implementation IQContactsDeletedIds

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"deleted_contact_ids" : @"objectIds",
                                                  @"current_date"        : @"serverDate"
                                                  }];
    return mapping;
}

@end
