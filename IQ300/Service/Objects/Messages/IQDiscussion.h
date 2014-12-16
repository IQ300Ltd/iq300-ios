//
//  IQDiscussion.h
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RKObjectMapping;
@class RKManagedObjectStore;
@class IQConversation;

@interface IQDiscussion : NSManagedObject

@property (nonatomic, strong) NSNumber * discussionId;
@property (nonatomic, strong) NSDate * createDate;
@property (nonatomic, strong) NSDate * updateDate;
@property (nonatomic, strong) NSString * pusherChannel;
@property (nonatomic, strong) NSSet * users;
@property (nonatomic, strong) NSSet * userViews;

@property (nonatomic, strong) IQConversation * conversation;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
