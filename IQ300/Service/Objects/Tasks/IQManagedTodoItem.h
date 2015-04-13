//
//  IQManagedTodoItem.h
//  IQ300
//
//  Created by Tayphoon on 24.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TodoItem.h"

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQManagedTodoItem : NSManagedObject <TodoItem>

@property (nonatomic, strong) NSNumber * itemId;
@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * completed;
@property (nonatomic, strong) NSNumber * position;
@property (nonatomic, strong) NSDate   * createdDate;
@property (nonatomic, strong) NSDate   * updatedDate;
@property (nonatomic, strong) NSNumber * destroy;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
