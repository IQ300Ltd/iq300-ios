//
//  IQComplexity.m
//  
//
//  Created by Vladislav Grigoryev on 29/02/16.
//
//

#import "IQComplexity.h"
#import "IQTask.h"

@implementation IQComplexity

@dynamic value;
@dynamic displayName;

+ (RKObjectMapping*)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store {
    RKEntityMapping * mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([self class]) inManagedObjectStore:store];
    [mapping setIdentificationAttributes:@[@"value"]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"value" : @"value",
                                                  @"translated_name" : @"displayName"
                                                  }];
    return mapping;
}


@end
