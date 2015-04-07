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
        item.taskId = object.taskId;
        item.title = object.title;
        item.completed = object.completed;
        item.position = object.position;
        item.createdDate = object.createdDate;
        item.updatedDate = object.updatedDate;
        return item;
    }
    return nil;
}

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"         : @"itemId",
                                                  @"task_id"    : @"taskId",
                                                  @"title"      : @"title",
                                                  @"completed"  : @"completed",
                                                  @"position"   : @"position",
                                                  @"created_at" : @"createdDate",
                                                  @"updated_at" : @"updatedDate",
                                                  @"_destroy"   : @"destroy"
                                                  }];
    return mapping;
}

+ (RKObjectMapping*)requestObjectMapping {
    RKObjectMapping * objectMapping = [self objectMapping];
    
    return [objectMapping inverseMapping];
}

- (id)copyWithZone:(NSZone *)zone {
    IQTodoItem * copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy.itemId = [self.itemId copyWithZone:zone];
        copy.taskId = [self.taskId copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.completed = [self.completed copyWithZone:zone];
        copy.position = [self.position copyWithZone:zone];
        copy.createdDate = [self.createdDate copyWithZone:zone];
        copy.updatedDate = [self.updatedDate copyWithZone:zone];
    }
    
    return copy;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.destroy = @(NO);
    }
    
    return self;
}

- (BOOL)isEqualToItem:(IQTodoItem*)item {
    if (item) {
        return [self.position isEqualToNumber:item.position] &&
               [self.title isEqualToString:item.title];
    }
    
    return NO;
}

@end
