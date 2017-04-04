//
//  IQForwardInfo.m
//  IQ300
//
//  Created by Viktor Sabanov on 04.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "IQForwardInfo.h"
#import "IQComment.h"
#import <RestKit/RestKit.h>

@implementation IQForwardInfo

@dynamic forwardCommentId;
@dynamic authorId;
@dynamic authorName;
@dynamic discussableId;
@dynamic discussableTitle;
@dynamic discussableType;
@dynamic discussableClass;
@dynamic source;

+ (RKObjectMapping *)objectMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    mapping.assignsDefaultValueForMissingAttributes = YES;
    mapping.deletionPredicate = [NSPredicate predicateWithFormat:@"forwardCommentId == %@ OR authorId == %@", @(0), @(0)];
    
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"comment_id"                : @"forwardCommentId",
                                                  @"comment_author_id"         : @"authorId",
                                                  @"comment_author_short_name" : @"authorName",
                                                  @"discussable_id"            : @"discussableId",
                                                  @"discussable_title"         : @"discussableTitle",
                                                  @"discussable_type"          : @"discussableType",
                                                  @"discussable_class"         : @"discussableClass"
                                                  }];
    
    return mapping;
}

@end
