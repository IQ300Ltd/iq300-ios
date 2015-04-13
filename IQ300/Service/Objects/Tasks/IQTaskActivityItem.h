//
//  IQTaskActivityItem.h
//  IQ300
//
//  Created by Tayphoon on 02.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQTaskActivityItem : NSManagedObject

@property (nonatomic, strong) NSNumber * itemId;
@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, strong) NSDate   * createdDate;
@property (nonatomic, strong) NSDate   * updatedDate;
@property (nonatomic, strong) NSNumber * authorId;
@property (nonatomic, strong) NSString * authorName;
@property (nonatomic, strong) NSString * event;
@property (nonatomic, strong) NSString * changes;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
