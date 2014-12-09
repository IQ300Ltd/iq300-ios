//
//  IQContact.m
//  IQ300
//
//  Created by Tayphoon on 09.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQContact.h"

@implementation IQContact

@dynamic contactId;
@dynamic createDate;
@dynamic ownerId;
@dynamic user;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"contactId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"               : @"contactId",
                                                  @"created_at"       : @"createDate",
                                                  @"owner_id"         : @"ownerId"
                                                  }];
    
    RKRelationshipMapping * relation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"contactor"
                                                                                   toKeyPath:@"user"
                                                                                 withMapping:[IQUser objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:relation];

    return mapping;
}

@end
