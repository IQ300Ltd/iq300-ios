//
//  IQForwardInfo.h
//  IQ300
//
//  Created by Viktor Sabanov on 04.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import <CoreData/CoreData.h>

@class IQComment;
@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQForwardInfo : NSManagedObject

@property (nonatomic, strong) NSNumber *forwardCommentId;
@property (nonatomic, strong) NSNumber *authorId;
@property (nonatomic, strong) NSString *authorName;
@property (nonatomic, strong) NSNumber *discussableId;
@property (nonatomic, strong) NSString *discussableTitle;
@property (nonatomic, strong) NSString *discussableType;
@property (nonatomic, strong) NSString *discussableClass;
@property (nonatomic, strong) IQComment *source;

+ (RKObjectMapping *)objectMappingForManagedObjectStore:(RKManagedObjectStore *)store;

@end
