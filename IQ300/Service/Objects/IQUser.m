//
//  IQUser.m
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQUser.h"
#import "NSManagedObject+ActiveRecord.h"

@implementation IQUser

@dynamic userId;
@dynamic displayName;
@dynamic nickName;
@dynamic email;
@dynamic pusherChannel;
@dynamic thumbUrl;
@dynamic mediumUrl;
@dynamic normalUrl;
@dynamic online;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    return [self objectMappingForEntityName:NSStringFromClass([self class]) store:store];
}

+ (RKObjectMapping*)objectMappingForEntityName:(NSString*)entityName store:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:entityName
                                                    inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"userId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id"               : @"userId",
                                                  @"short_name"       : @"displayName",
                                                  @"mention_name"     : @"nickName",
                                                  @"email"            : @"email",
                                                  @"pusher_channel"   : @"pusherChannel",
                                                  @"photo.thumb_url"  : @"thumbUrl",
                                                  @"photo.medium_url" : @"mediumUrl",
                                                  @"photo.normal_url" : @"normalUrl",
                                                  @"online"           : @"online"
                                                  }];
    return mapping;
}

+ (IQUser*)userWithId:(NSNumber *)userId inContext:(NSManagedObjectContext *)context {
    IQUser * user = [IQUser objectWithPredicate:[NSPredicate predicateWithFormat:@"userId == %@", userId] inContext:context];
    return user;
}

@end
