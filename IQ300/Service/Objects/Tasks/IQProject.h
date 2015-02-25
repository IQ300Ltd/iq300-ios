//
//  IQProject.h
//  IQ300
//
//  Created by Tayphoon on 24.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQProject : NSManagedObject

@property (nonatomic, strong) NSNumber * projectId;
@property (nonatomic, strong) NSString * title;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
