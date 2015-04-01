//
//  IQTodoItem.m
//  IQ300
//
//  Created by Tayphoon on 31.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQTodoItem.h"

@implementation IQTodoItem

+ (IQTodoItem*)itemFromObject:(id<TodoItem>)object {
    if (object) {
        IQTodoItem * item = [[IQTodoItem alloc] init];
        item.itemId = object.itemId;
        item.title = object.title;
        item.completed = object.completed;
        item.position = object.position;
        item.createdDate = object.createdDate;
        item.updatedDate = object.updatedDate;
        return item;
    }
    return nil;
}

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
