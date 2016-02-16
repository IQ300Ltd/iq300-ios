//
//  IQReconciliation.m
//  
//
//  Created by Vladislav Grigoryev on 16/02/16.
//
//

#import "IQReconciliation.h"
#import <RestKit/RestKit.h>


@implementation IQReconciliation

@dynamic approvedCount;
@dynamic waitingCount;
@dynamic totalCount;
@dynamic reconciliationId;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"reconciliationId"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"list_id"  : @"reconciliationId",
                                                  @"approved" : @"approvedCount",
                                                  @"waiting"  : @"waitingCount",
                                                  @"total"    : @"totalCount",
                                                  }];
    
    return mapping;
}


@end
