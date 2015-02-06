//
//  IQNotification.h
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQUser.h"

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQNotificable : NSManagedObject

@property (nonatomic, strong) NSNumber * notificableId;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * title;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end

@interface IQNotification : NSManagedObject

@property (nonatomic, strong) NSNumber * notificationId;
@property (nonatomic, strong) NSString * groupSid;
@property (nonatomic, strong) NSNumber * readed;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSDate * updatedAt;
@property (nonatomic, strong) NSNumber * hasActions;
@property (nonatomic, strong) IQNotificable * notificable;
@property (nonatomic, strong) NSString * mainDescription;
@property (nonatomic, strong) NSString * additionalDescription;
@property (nonatomic, strong) IQUser * user;
@property (nonatomic, strong) NSNumber * ownerId;
@property (nonatomic, strong) NSSet * availableActions;
@property (nonatomic, strong) NSNumber * hasDiscussion;
@property (nonatomic, strong) NSNumber * discussionId;
@property (nonatomic, strong) NSNumber * commentId;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
