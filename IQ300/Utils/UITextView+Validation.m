//
//  UITextView+Validation.m
//  IQ300
//
//  Created by Tayphoon on 29.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <objc/runtime.h>

#import "UITextView+Validation.h"

static const void * UITextViewValidatorKey = &UITextViewValidatorKey;
static const void * UITextViewisValidKey = &UITextViewisValidKey;
static const void * UITextViewValidationErrorKey = &UITextViewValidationErrorKey;

@implementation UITextView (Validation)

- (void)setValidator:(id<IQValueValidator>)validator {
    objc_setAssociatedObject(self, &UITextViewValidatorKey, validator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<IQValueValidator>)validator {
    return objc_getAssociatedObject(self, &UITextViewValidatorKey);
}

- (void)setValidationError:(NSError *)validationError {
    objc_setAssociatedObject(self, &UITextViewValidationErrorKey, validationError, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSError*)validationError {
    return objc_getAssociatedObject(self, &UITextViewValidationErrorKey);
}

- (void)setIsValueValid:(BOOL)valid {
    objc_setAssociatedObject(self, &UITextViewisValidKey, @(valid), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isValid {
    return [objc_getAssociatedObject(self, &UITextViewisValidKey) boolValue];
}

- (void)validateValue {
    if (self.validator) {
        NSError * validationError = nil;
        BOOL isValueValid = [self.validator validate:self.text error:&validationError];
        [self setIsValueValid:isValueValid];
        [self setValidationError:validationError];
    }
}

@end
