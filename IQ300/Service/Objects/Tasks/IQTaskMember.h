//
//  IQTaskMember.h
//  IQ300
//
//  Created by Tayphoon on 23.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQUser;
@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQTaskMember : NSManagedObject

@property (nonatomic, strong) NSNumber * memberId;
@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSDate   * createdDate;
@property (nonatomic, strong) NSDate   * updatedDate;
@property (nonatomic, strong) NSString * taskRole;
@property (nonatomic, strong) NSString * taskRoleName;
@property (nonatomic, strong) NSString * communityRole;
@property (nonatomic, strong) NSString * communityRoleName;

@property (nonatomic, strong) IQUser * user;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
