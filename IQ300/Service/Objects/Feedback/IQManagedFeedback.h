//
//  IQFeedback.h
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <CoreData/CoreData.h>

@class IQUser;
@class IQFeedbackCategory;
@class RKObjectMapping;
@class RKManagedObjectStore;
@class IQFeedbackType;

@interface IQManagedFeedback : NSManagedObject

@property (nonatomic, strong) NSNumber * feedbackId;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * feedbackDescription;
@property (nonatomic, strong) NSNumber * discussionId;
@property (nonatomic, strong) NSDate * createdDate;
@property (nonatomic, strong) NSDate * updatedDate;
@property (nonatomic, strong) NSNumber * commentsCount;

@property (nonatomic, strong) IQUser * author;
@property (nonatomic, strong) IQFeedbackType * feedbackType;
@property (nonatomic, strong) IQFeedbackCategory * category;
@property (nonatomic, strong) NSOrderedSet * attachments;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
