//
//  IQNotificationsGroup.m
//  IQ300
//
//  Created by Tayphoon on 30.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQNotificationsGroup.h"
#import "IQNotification.h"

@implementation IQNotificationsGroup

@dynamic sID;
@dynamic totalCount;
@dynamic unreadCount;
@dynamic ownerId;
@dynamic firstNotificationId;
@dynamic lastNotificationId;
@dynamic lastNotification;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:@"IQNotificationsGroup" inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"sID"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"sid"                            : @"sID",
                                                  @"total_count"                    : @"totalCount",
                                                  @"unread_count"                   : @"unreadCount",
                                                  @"last_notification.recipient_id" : @"ownerId",
                                                  @"first_notice_id"                : @"firstNotificationId",
                                                  @"last_notice_id"                 : @"lastNotificationId"
                                                  }];
    
    RKRelationshipMapping * userRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"last_notification"
                                                                                       toKeyPath:@"lastNotification"
                                                                                     withMapping:[IQNotification objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:userRelation];

    return mapping;
}

@end
