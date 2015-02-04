//
//  IQNotificationsGroup.h
//  IQ300
//
//  Created by Tayphoon on 30.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQUser.h"

@class RKObjectMapping;
@class RKManagedObjectStore;
@class IQNotification;

@interface IQNotificationsGroup : NSManagedObject

/**
 *  String identifier notifications group.
 */
@property (nonatomic, strong) NSString * sID;
@property (nonatomic, strong) NSNumber * totalCount;
@property (nonatomic, strong) NSNumber * unreadCount;
@property (nonatomic, strong) NSNumber * firstNotificationId;
@property (nonatomic, strong) NSNumber * lastNotificationId;
@property (nonatomic, strong) NSNumber * ownerId;

@property (nonatomic, strong) IQNotification * lastNotification;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
