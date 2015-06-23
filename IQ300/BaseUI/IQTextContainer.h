//
//  IQTextContainer.h
//  IQ300
//
//  Created by Tayphoon on 17.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "BottomLineView.h"
#import "ExTextField.h"
#import "IQValueValidator.h"

@interface IQTextContainer : BottomLineView

@property (nonatomic, readonly) ExTextField * textField;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, strong) id<IQValueValidator> validator;
@property (nonatomic, readonly) NSError * validationError;

/**
 *  Return YES if last value in textfield validated
 *
 *  @return YES for valid, no otherwise
 */
- (BOOL)isValid;

- (void)validateValue;

- (void)setLocalizedPlaceholder:(NSString*)placeholder;

@end
