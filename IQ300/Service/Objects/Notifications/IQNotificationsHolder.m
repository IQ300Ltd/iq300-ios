//
//  IQNotificationsHolder.m
//  IQ300
//
//  Created by Tayphoon on 18.02.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQNotificationsHolder.h"

@implementation IQNotificationsHolder

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore *)store {
    RKObjectMapping * mapping = [super objectMappingForManagedObjectStore:store];
    
    RKRelationshipMapping * notificationsRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"notifications"
                                                                                                toKeyPath:@"objects"
                                                                                              withMapping:[IQNotification objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:notificationsRelation];
    return mapping;
}

@end
