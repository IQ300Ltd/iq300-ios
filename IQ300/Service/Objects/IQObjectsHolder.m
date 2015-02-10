//
//  IQObjectsHolder.m
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>

#import "IQObjectsHolder.h"

@implementation IQObjectsHolder

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    
    RKObjectMapping * mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"meta.collection_info.current_page"  : @"currentPage",
                                                  @"meta.collection_info.total_pages"   : @"totalPages",
                                                  @"meta.collection_info.total_count"   : @"totalCount"
                                                  }];
    
    return mapping;
}

@end
