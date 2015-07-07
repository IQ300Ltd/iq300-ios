//
//  UITextView+Validation.h
//  IQ300
//
//  Created by Tayphoon on 29.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQValueValidator.h"

@interface UITextView (Validation)

@property (nonatomic, strong) id<IQValueValidator> validator;
@property (nonatomic, readonly) NSError * validationError;

/**
 *  Return YES if last value in textfield validated
 *
 *  @return YES for valid, no otherwise
 */
- (BOOL)isValid;

- (void)validateValue;

@end
