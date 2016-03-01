//
//  IQComplexity.h
//  
//
//  Created by Vladislav Grigoryev on 29/02/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <RestKit/RestKit.h>

@interface IQComplexity : NSManagedObject

@property (nonatomic, retain) NSNumber *value;
@property (nonatomic, retain) NSString *displayName;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end
