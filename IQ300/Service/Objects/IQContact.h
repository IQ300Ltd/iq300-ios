//
//  IQContact.h
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "IQUser.h"

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQContact : NSManagedObject

@property (nonatomic, strong) NSNumber * contactId;
@property (nonatomic, strong) NSDate * createDate;
@property (nonatomic, strong) NSNumber * ownerId;
@property (nonatomic, strong) IQUser * user;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
