//
//  IQTask.h
//  IQ300
//
//  Created by Tayphoon on 20.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IQUser;
@class IQCommunity;
@class IQProject;
@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQTask : NSManagedObject

@property (nonatomic, strong) NSNumber     * taskId;
@property (nonatomic, strong) NSString     * type;
@property (nonatomic, strong) NSNumber     * recipientId;
@property (nonatomic, strong) NSNumber     * ownerId;
@property (nonatomic, strong) NSString     * ownerType;
@property (nonatomic, strong) NSString     * status;
@property (nonatomic, strong) NSString     * title;
@property (nonatomic, strong) NSString     * taskDescription;
@property (nonatomic, strong) NSDate       * startDate;
@property (nonatomic, strong) NSDate       * endDate;
@property (nonatomic, strong) NSDate       * createdDate;
@property (nonatomic, strong) NSDate       * updatedDate;
@property (nonatomic, strong) NSNumber     * templateId;
@property (nonatomic, strong) NSNumber     * parentId;
@property (nonatomic, strong) NSNumber     * duration;
@property (nonatomic, strong) NSNumber     * position;
@property (nonatomic, strong) NSNumber     * discussionId;
@property (nonatomic, strong) NSNumber     * commentsCount;

@property (nonatomic, strong) IQUser       * customer;
@property (nonatomic, strong) IQUser       * executor;
@property (nonatomic, strong) IQCommunity  * community;
@property (nonatomic, strong) IQProject    * project;

@property (nonatomic, strong) NSSet        * childIds;
@property (nonatomic, strong) NSSet        * availableActions;
@property (nonatomic, strong) NSOrderedSet * todoItems;
@property (nonatomic, strong) NSOrderedSet * attachments;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
