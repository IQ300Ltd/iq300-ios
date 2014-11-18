//
//  IQServiceResponse.m
//  IQ300
//
//  Created by Tayphoon on 18.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import "RestKit/RestKit.h"
#import "IQServiceResponse.h"

@interface NSObject()

+ (RKObjectMapping *)objectMappingForManagedObjectStore:(RKManagedObjectStore*)store;

@end

@implementation IQServiceResponse

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping* objectMapping = [RKObjectMapping mappingForClass:[IQServiceResponse class]];
    [objectMapping addAttributeMappingsFromDictionary:@{
                                                        @"ResultCode": @"resultCode",
                                                        @"ResultCodeName": @"resultDescription",
                                                        @"ErrorMessage": @"errorMessage"
                                                        }];
    
    return objectMapping;
}

+ (RKResponseDescriptor*)responseDescriptorForClass:(Class)class
                                             method:(NSInteger)method
                                        pathPattern:(NSString*)pathPattern
                                              store:(RKManagedObjectStore*)store {
    NSString * fromKeyPath = [NSString stringWithFormat:@"%@", class];
    return [self responseDescriptorForClass:class
                                     method:method
                                pathPattern:pathPattern
                                fromKeyPath:fromKeyPath
                                      store:store];
}

+ (RKResponseDescriptor*)responseDescriptorForClass:(Class)class
                                             method:(NSInteger)method
                                        pathPattern:(NSString*)pathPattern
                                        fromKeyPath:(NSString*)fromKeyPath
                                              store:(RKManagedObjectStore*)store {
    RKObjectMapping * serviceResponseMapping = [self objectMapping];
    
    RKMapping * objectMapping = ([class respondsToSelector:@selector(objectMapping)]) ? [class objectMapping] : nil;
    if(!objectMapping) {
        BOOL isEntityMapping = [class respondsToSelector:@selector(objectMappingForManagedObjectStore:)];
        objectMapping = (isEntityMapping) ? [class objectMappingForManagedObjectStore:store] : nil;
    }
    
    if(objectMapping) {
        RKRelationshipMapping * relationship = [RKRelationshipMapping relationshipMappingFromKeyPath:fromKeyPath
                                                                                           toKeyPath:@"returnedValue"
                                                                                         withMapping:objectMapping];
        
        [serviceResponseMapping addPropertyMapping:relationship];
    }
    
    RKResponseDescriptor * descriptor = [RKResponseDescriptor responseDescriptorWithMapping:serviceResponseMapping
                                                                                     method:method
                                                                                pathPattern:pathPattern
                                                                                    keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    return descriptor;
}

@end
