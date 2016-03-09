//
//  IQAttachment.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQManagedAttachment.h"

@implementation IQManagedAttachment

@dynamic attachmentId;
@dynamic localId;
@dynamic createDate;
@dynamic displayName;
@dynamic atDescription;
@dynamic ownerId;
@dynamic contentType;
@dynamic unifiedContentType;
@dynamic originalURL;
@dynamic previewURL;
@dynamic localURL;
@dynamic unread;

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
                                                  @"urls.preview"         : @"previewURL",
                                                  @"unread"               : @"unread"
                                                  }];
    return mapping;
}

+ (NSNumber*)uniqueLocalIdInContext:(NSManagedObjectContext*)context  error:(NSError**)error {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription * description = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    [request setEntity:description];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"localId" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [request setFetchLimit:1];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:@[@"localId"]];
    
    NSArray * fetchedObjects = [context executeFetchRequest:request error:error];
    NSDictionary * result = [fetchedObjects firstObject];
    if (result != nil) {
        NSInteger localId = [result[@"localId"] integerValue];
        return @(localId+1);
    }
    else if(!*error && [fetchedObjects count] == 0) {
        return @(0);
    }
    return nil;
}

@end
