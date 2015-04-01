//
//  IQManagedTodoItem.m
//  IQ300
//
//  Created by Tayphoon on 24.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQManagedTodoItem.h"

@implementation IQManagedTodoItem

@dynamic itemId;
@dynamic title;
@dynamic completed;
@dynamic position;
@dynamic createdDate;
@dynamic updatedDate;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"itemId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"         : @"itemId",
                                                  @"title"      : @"title",
                                                  @"completed"  : @"completed",
                                                  @"position"   : @"position",
                                                  @"created_at" : @"createdDate",
                                                  @"updated_at" : @"updatedDate"
                                                  }];
    return mapping;
}

@end
