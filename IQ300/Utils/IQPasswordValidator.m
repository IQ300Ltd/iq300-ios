//
//  IQPasswordValidator.m
//  IQ300
//
//  Created by Tayphoon on 18.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQPasswordValidator.h"

NSString * const IQPasswordValidatorErrorDomain = @"com.iq300.IQPasswordValidator";

@implementation IQPasswordValidator

+ (instancetype)validator {
    return [[IQPasswordValidator alloc] init];
}

- (BOOL)validate:(NSString *)value error:(NSError**)error {
    BOOL isValid = ([super validate:value error:error]);
    if (isValid && [value length] < 6 && error) {
        NSString * errorDescription = NSLocalizedStringFromTable(@"Password is too short (can be less than 6 characters)", @"IQValidatorLocalization", nil);
        NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : errorDescription };
        *error = [NSError errorWithDomain:IQPasswordValidatorErrorDomain
                                     code:-1
                                 userInfo:userInfo];
        return NO;
    }
    return isValid;
}

@end
