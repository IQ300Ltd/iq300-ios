//
//  IQStringValidator.h
//  IQ300
//
//  Created by Tayphoon on 18.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQValueValidator.h"

extern NSString * const IQStringValidatorErrorDomain;

@interface IQStringValidator : NSObject<IQValueValidator>

@property (nonatomic, strong) NSString * errorDescription;

+ (instancetype)validator;

- (BOOL)validate:(NSString*)value error:(NSError**)error;

@end
