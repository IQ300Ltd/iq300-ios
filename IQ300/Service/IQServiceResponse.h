//
//  IQServiceResponse.h
//  IQ300
//
//  Created by Tayphoon on 18.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "TCResponse.h"

@class RKResponseDescriptor;
@class RKManagedObjectStore;
@class RKObjectMapping;

@interface IQServiceResponse : NSObject<TCResponse>

@property (nonatomic, strong) id returnedValue;
@property (nonatomic, strong) NSNumber * statusCode;
@property (nonatomic, strong) NSString * statusMessage;
@property (nonatomic, strong) NSString * errorMessage;

+ (RKObjectMapping*)objectMapping;
+ (RKResponseDescriptor*)responseDescriptorForClass:(Class)class method:(NSInteger)method pathPattern:(NSString*)pathPattern store:(RKManagedObjectStore*)store;
+ (RKResponseDescriptor*)responseDescriptorForClass:(Class)class method:(NSInteger)method pathPattern:(NSString*)pathPattern fromKeyPath:(NSString*)fromKeyPath
                                              store:(RKManagedObjectStore*)store;

+ (RKResponseDescriptor*)responseDescriptorForClasses:(NSArray*)classes method:(NSInteger)method pathPattern:(NSString*)pathPattern fromKeyPath:(NSString*)fromKeyPath
                                                store:(RKManagedObjectStore*)store;

@end
