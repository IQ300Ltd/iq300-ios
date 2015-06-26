//
//  IQFeedback.m
//  IQ300
//
//  Created by Tayphoon on 26.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQManagedFeedback.h"
#import "IQUser.h"
#import "IQFeedbackCategory.h"
#import "IQAttachment.h"

@implementation IQManagedFeedback

@dynamic feedbackId;
@dynamic type;
@dynamic state;
@dynamic feedbackDescription;
@dynamic discussionId;
@dynamic createdDate;
@dynamic author;
@dynamic category;
@dynamic attachments;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class])
                                                    inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"feedbackId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"            : @"feedbackId",
                                                  @"report_type"   : @"type",
                                                  @"description"   : @"feedbackDescription",
                                                  @"state"         : @"state",
                                                  @"discussion_id" : @"discussionId",
                                                  @"created_date"  : @"createdDate"
                                                  }];
    
    RKRelationshipMapping * relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"author"
                                                                                   toKeyPath:@"author"
                                                                                 withMapping:[IQUser objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"category"
                                                           toKeyPath:@"category"
                                                         withMapping:[IQFeedbackCategory objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"attachments"
                                                           toKeyPath:@"attachments"
                                                         withMapping:[IQAttachment objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];
    
    return mapping;

}

@end
