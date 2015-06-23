//
//  IQStringValidator.m
//  IQ300
//
//  Created by Tayphoon on 18.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQStringValidator.h"

NSString * const IQStringValidatorErrorDomain = @"com.iq300.IQStringValidator";

@implementation IQStringValidator

+ (instancetype)validator {
    return [[IQStringValidator alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        _errorDescription = NSLocalizedStringFromTable(@"%@ can not be empty", @"IQValidatorLocalization", nil);
    }
    return self;
}

- (BOOL)validate:(NSString*)value error:(NSError**)error {
    BOOL isValid = ([value length] > 0);
    if (!isValid && error) {
        NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : self.errorDescription };
        *error = [NSError errorWithDomain:IQStringValidatorErrorDomain
                                     code:-1
                                 userInfo:userInfo];
    }
    return isValid;
}

@end
