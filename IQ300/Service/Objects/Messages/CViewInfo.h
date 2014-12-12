//
//  CViewInfo.h
//  IQ300
//
//  Created by Tayphoon on 11.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface CViewInfo : NSManagedObject

@property (nonatomic, strong) NSNumber * userId;
@property (nonatomic, strong) NSNumber * discussionId;
@property (nonatomic, strong) NSDate * viewDate;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
