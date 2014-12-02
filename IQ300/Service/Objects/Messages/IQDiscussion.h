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

@interface IQDiscussion : NSManagedObject

@property (nonatomic, strong) NSNumber * discussionId;
@property (nonatomic, strong) NSDate * createDate;
@property (nonatomic, strong) NSDate * updateDate;
@property (nonatomic, strong) NSString * pusherChannel;
@property (nonatomic, strong) NSArray * users;
@property (nonatomic, strong) NSArray * userViews;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
