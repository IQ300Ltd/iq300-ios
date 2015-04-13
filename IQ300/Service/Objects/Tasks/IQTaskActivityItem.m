//
//  IQTaskActivityItem.m
//  IQ300
//
//  Created by Tayphoon on 02.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQTaskActivityItem.h"

@implementation IQTaskActivityItem

@dynamic itemId;
@dynamic taskId;
@dynamic createdDate;
@dynamic updatedDate;
@dynamic authorId;
@dynamic authorName;
@dynamic event;
@dynamic changes;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"itemId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"                : @"itemId",
                                                  @"task_id"           : @"taskId",
                                                  @"created_at"        : @"createdDate",
                                                  @"updated_at"        : @"updatedDate",
                                                  @"author.id"         : @"authorId",
                                                  @"author.short_name" : @"authorName",
                                                  @"event"             : @"event",
                                                  @"changes"           : @"changes"
                                                  }];
    return mapping;
}

@end
