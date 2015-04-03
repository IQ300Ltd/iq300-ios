//
//  IQTaskHistoryItem.h
//  IQ300
//
//  Created by Tayphoon on 02.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQTaskHistoryItem : NSManagedObject

@property (nonatomic, strong) NSNumber * itemId;
@property (nonatomic, strong) NSDate * createdDate;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSNumber * ownerId;
@property (nonatomic, strong) NSString * mainDescription;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
