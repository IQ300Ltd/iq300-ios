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

@interface IQComment : NSManagedObject

@property (nonatomic, strong) NSNumber * commentId;
@property (nonatomic, strong) NSNumber * discussionId;
@property (nonatomic, strong) NSDate * createDate;
@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) IQUser * author;
@property (nonatomic, strong) NSSet * attachments;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
