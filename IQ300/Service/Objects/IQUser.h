//
//  IQUser.h
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQUser : NSManagedObject

@property (nonatomic, strong) NSNumber * userId;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * thumbUrl;
@property (nonatomic, strong) NSString * mediumUrl;
@property (nonatomic, strong) NSString * normalUrl;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
