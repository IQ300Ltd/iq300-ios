//
//  IQNotificationsHolder.m
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQNotificationsHolder.h"

@implementation IQNotificationsHolder

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"meta.collection_info.current_page"  : @"currentPage",
                                                  @"meta.collection_info.total_pages"   : @"totalPages",
                                                  @"meta.collection_info.total_count"   : @"totalCount"
                                                  }];
    
    RKRelationshipMapping * notificationsRelation = [RKRelationshipMapping relationshipMappingFromKeyPath:@"notifications"
                                                                                                toKeyPath:@"notifications"
                                                                                              withMapping:[IQNotification objectMappingForManagedObjectStore:store]];
    [mapping addPropertyMapping:notificationsRelation];
    
    return mapping;
}

@end
