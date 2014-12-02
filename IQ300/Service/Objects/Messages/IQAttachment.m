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
                                                  @"id"                   : @"attachmentId",
                                                  @"created_at"           : @"createDate",
                                                  @"display_name"         : @"displayName",
                                                  @"description"          : @"atDescription",
                                                  @"author_id"            : @"ownerId",
                                                  @"content_type"         : @"contentType",
                                                  @"unified_content_type" : @"unifiedContentType",
                                                  @"urls.original"        : @"originalURL",
                                                  @"urls.preview"         : @"previewURL"
                                                  }];
    return mapping;
}

@end
