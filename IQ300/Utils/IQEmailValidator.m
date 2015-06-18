//
//  IQEmailValidator.m
//  IQ300
//
//  Created by Tayphoon on 18.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQEmailValidator.h"

NSString * const IQEmailValidatorErrorDomain = @"com.iq300.IQEmailValidator";

@implementation IQEmailValidator

+ (instancetype)validator {
    return [[IQEmailValidator alloc] init];
}

- (BOOL)validate:(NSString *)value error:(NSError**)error {
    BOOL stricterFilter = NO;
    NSString * stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString * laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString * emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    NSError * validationError = nil;
    BOOL isValid = ([super validate:value error:&validationError] && [emailTest evaluateWithObject:value]);
    if (!validationError) {
        NSString * errorDescription = NSLocalizedStringFromTable(@"Email address is invalid", @"IQValidatorLocalization", nil);
        NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : errorDescription };
        validationError = [NSError errorWithDomain:IQEmailValidatorErrorDomain
                                              code:-1
                                          userInfo:userInfo];
    }
    
    if (error) {
        *error = validationError;
    }
    
    return isValid;
}

@end
