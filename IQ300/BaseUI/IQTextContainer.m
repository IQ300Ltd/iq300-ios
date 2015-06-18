//
//  IQTextContainer.m
//  IQ300
//
//  Created by Tayphoon on 17.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTextContainer.h"

@interface IQTextContainer() {
    BOOL _isValueValid;
    NSError * _validationError;
}

@end

@implementation IQTextContainer

- (id)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.bottomLineColor = [UIColor colorWithHexInt:0xc8c9c9];
        self.bottomLineHeight = 0.5f;
        
        _textField = [[ExTextField alloc] init];
        _textField.font = [UIFont fontWithName:IQ_HELVETICA size:16];
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self addSubview:_textField];
    }
    
    return self;
}

- (BOOL)isValid {
    return _isValueValid;
}

- (NSError*)validationError {
    return _validationError;
}

- (void)setLocalizedPlaceholder:(NSString*)placeholder {
    if (placeholder) {
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(placeholder, nil)
                                                                           attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexInt:0xb6b6b6]}];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = UIEdgeInsetsInsetRect(self.bounds, _contentInsets);
    _textField.frame = actualBounds;
}

- (void)validateValue {
    NSError * validationError = nil;
    _isValueValid = [self.validator validate:_textField.text error:&validationError];
    _validationError = validationError;
}

@end
