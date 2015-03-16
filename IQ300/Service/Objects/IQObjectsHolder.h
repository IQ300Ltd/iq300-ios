//
//  IQObjectsHolder.h
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQObjectsHolder : NSObject

@property (nonatomic, strong) NSOrderedSet * objects;
@property (nonatomic, strong) NSNumber * currentPage;
@property (nonatomic, strong) NSNumber * totalPages;
@property (nonatomic, strong) NSNumber * totalCount;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
