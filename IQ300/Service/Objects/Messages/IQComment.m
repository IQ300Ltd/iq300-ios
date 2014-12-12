//
//  IQComment.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQComment.h"

@implementation IQComment

@dynamic commentId;
@dynamic localId;
@dynamic discussionId;
@dynamic createDate;
@dynamic body;
@dynamic author;
@dynamic attachments;
@dynamic commentStatus;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"commentId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"            : @"commentId",
                                                  @"discussion_id" : @"discussionId",
                                                  @"created_at"    : @"createDate",
                                                  @"body"          : @"body"
                                                  }];
    
    RKRelationshipMapping * relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"author"
                                                                                   toKeyPath:@"author"
                                                                                 withMapping:[IQUser objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"attachments"
                                                           toKeyPath:@"attachments"
                                                         withMapping:[IQAttachment objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];

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
