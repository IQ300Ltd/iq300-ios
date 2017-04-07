//
//  IQSubtask.h
//  IQ300
//
//  Created by Vladislav Grigoriev on 23/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQUser;
@class IQCommunity;
@class IQProject;
@class IQReconciliation;
@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQSubtask : NSManagedObject

@property (nonatomic, strong) NSNumber    * subtaskId;
@property (nonatomic, strong) NSString    * type;
@property (nonatomic, strong) NSString    * status;
@property (nonatomic, strong) NSString    * title;

@property (nonatomic, strong) NSDate      * startDate;
@property (nonatomic, strong) NSDate      * endDate;
@property (nonatomic, strong) NSDate      * createdDate;
@property (nonatomic, strong) NSDate      * updatedDate;

@property (nonatomic, strong) NSNumber    * parentId;

@property (nonatomic, strong) NSNumber    * hasAccess;
@property (nonatomic, strong) NSNumber    * priority;

@property (nonatomic, strong) IQUser      * customer;
@property (nonatomic, strong) IQUser      * executor;
@property (nonatomic, strong) IQCommunity * community;
@property (nonatomic, strong) IQProject   * project;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
