//
//  IQCommunity.h
//  IQ300
//
//  Created by Tayphoon on 24.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQCommunity : NSManagedObject

@property (nonatomic, strong) NSNumber * communityId;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * thumbUrl;
@property (nonatomic, strong) NSString * mediumUrl;
@property (nonatomic, strong) NSString * normalUrl;
@property (nonatomic, strong) NSNumber * sortOrder;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
