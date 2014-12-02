//
//  IQAttachment.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQAttachment.h"

@implementation IQAttachment

@dynamic attachmentId;
@dynamic createDate;
@dynamic displayName;
@dynamic atDescription;
@dynamic ownerId;
@dynamic contentType;
@dynamic unifiedContentType;
@dynamic originalURL;
@dynamic previewURL;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"attachmentId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"               : @"attachmentId",
                                                  @"short_name"       : @"createDate",
                                                  @"email"            : @"displayName",
                                                  @"pusher_channel"   : @"atDescription",
                                                  @"photo.thumb_url"  : @"contentType",
                                                  @"photo.medium_url" : @"unifiedContentType",
                                                  @"photo.normal_url" : @"originalURL",
                                                  @"photo.normal_url" : @"previewURL"
                                                  }];
    return mapping;
}

@end
