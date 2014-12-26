//
//  IQComment.h
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQUser.h"
#import "IQAttachment.h"

@class RKObjectMapping;
@class RKManagedObjectStore;

typedef NS_ENUM(NSUInteger, IQCommentStatus) {
    IQCommentStatusUnknown = -1,
    IQCommentStatusViewed = 0,
    IQCommentStatusSent = 1,
    IQCommentStatusSendError = 2
};

@interface IQComment : NSManagedObject

@property (nonatomic, strong) NSNumber * commentId;
@property (nonatomic, strong) NSNumber * localId;
@property (nonatomic, strong) NSNumber * discussionId;
@property (nonatomic, strong) NSDate * createDate;
@property (nonatomic, strong) NSDate * createShortDate;
@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) IQUser * author;
@property (nonatomic, strong) NSSet * attachments;
@property (nonatomic, strong) NSNumber * commentStatus;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

+ (NSNumber*)uniqueLocalIdInContext:(NSManagedObjectContext*)context error:(NSError**)error;

@end
