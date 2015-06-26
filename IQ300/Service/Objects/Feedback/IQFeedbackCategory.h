//
//  IQFeedbackCategory.h
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQFeedbackCategory : NSManagedObject

@property (nonatomic, strong) NSNumber * categoryId;
@property (nonatomic, strong) NSString * title;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
