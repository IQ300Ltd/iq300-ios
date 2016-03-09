//
//  IQAttachment.h
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "IQAttachment.h"

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQManagedAttachment : NSManagedObject <IQAttachment>

@property (nonatomic, strong) NSNumber * attachmentId;
@property (nonatomic, strong) NSNumber * localId;
@property (nonatomic, strong) NSDate   * createDate;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * atDescription;
@property (nonatomic, strong) NSNumber * ownerId;
@property (nonatomic, strong) NSString * contentType;
@property (nonatomic, strong) NSString * unifiedContentType;
@property (nonatomic, strong) NSString * originalURL;
@property (nonatomic, strong) NSString * localURL;
@property (nonatomic, strong) NSString * previewURL;
@property (nonatomic, strong) NSNumber * unread;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

+ (NSNumber*)uniqueLocalIdInContext:(NSManagedObjectContext*)context error:(NSError**)error;

@end
