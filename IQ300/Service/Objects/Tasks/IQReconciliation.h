//
//  IQReconciliation.h
//  
//
//  Created by Vladislav Grigoryev on 16/02/16.
//
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;
@class RKManagedObjectStore;

@interface IQReconciliation : NSManagedObject

@property (nonatomic, retain) NSNumber *approvedCount;
@property (nonatomic, retain) NSNumber *waitingCount;
@property (nonatomic, retain) NSNumber *totalCount;
@property (nonatomic, retain) NSNumber *reconciliationId;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
