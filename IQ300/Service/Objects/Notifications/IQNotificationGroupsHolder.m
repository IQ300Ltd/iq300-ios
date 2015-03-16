//
//  Notifications.m
//  IQ300
//
//  Created by Tayphoon on 10.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQNotificationGroupsHolder.h"

@implementation IQNotificationGroupsHolder

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKObjectMapping * mapping = [super objectMappingForManagedObjectStore:store];
    
    RKRelationshipMapping * notificationsRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"notification_groups"
                                                                                                toKeyPath:@"objects"
                                                                                              withMapping:[IQNotificationsGroup objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:notificationsRelation];
    return mapping;
}

@end
