//
//  IQFeedbackType.h
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQFeedbackType : NSManagedObject

@property (nonatomic, strong) NSNumber * typeId;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * title;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
