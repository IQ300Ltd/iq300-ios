//
//  TaskEstimatedTimeCell.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 29/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "IQTextCell.h"
#import "IQEstimatedTimeCell.h"
#import "IQTaskEstimatedTimeItem.h"

#define COMMA_INSET 2.0f
#define HOURS_INSET 0.0f
#define HOURS_WIDHT_ADDITION 10.0f

@interface IQEstimatedTimeCell () <UITextFieldDelegate> {
    UIEdgeInsets _contentInsets;
}

@end

@implementation IQEstimatedTimeCell

+ (CGFloat)heightForItem:(IQTaskEstimatedTimeItem *)item width:(CGFloat)width {
    CGFloat actualWidht = width - CONTENT_HORIZONTAL_INSETS;
    CGFloat height = CONTENT_VERTICAL_INSETS * 2.0f;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = TEXT_FONT;
    label.textColor = TEXT_COLOR;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"%@::", NSLocalizedString(@"Estimated time", nil)];
    
    CGSize labelSize = [label sizeThatFits:CGSizeMake(actualWidht, CGFLOAT_MAX)];
    
    UITextField *textView = [[UITextField alloc] init];
    textView.font = TEXT_FONT;
    textView.textColor = TEXT_COLOR;
    textView.textAlignment = NSTextAlignmentCenter;
    textView.backgroundColor = [UIColor clearColor];
    textView.returnKeyType = UIReturnKeyNext;
    
    [textView setText:@"000"];
    CGSize hoursSize = [textView sizeThatFits:CGSizeMake(actualWidht, CGFLOAT_MAX)];
    
    [textView setText:@"00"];
    CGSize minutesSize = [textView sizeThatFits:CGSizeMake(actualWidht, CGFLOAT_MAX)];
    
    height += MAX(labelSize.height, MAX(minutesSize.height, hoursSize.height));
    return MAX(height, CELL_MIN_HEIGHT);

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _contentInsets = UIEdgeInsetsMake(CONTENT_VERTICAL_INSETS,
                                          CONTENT_HORIZONTAL_INSETS + 5.0f,
                                          CONTENT_VERTICAL_INSETS,
                                          0.0f);
        
        self.backgroundColor = [UIColor whiteColor];
        super.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.font = TEXT_FONT;
        _label.textColor = TEXT_COLOR;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor clearColor];
        _label.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Estimated time", nil)];
        [self.contentView addSubview:_label];
        
        _commaLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _commaLabel.font = TEXT_FONT;
        _commaLabel.textColor = TEXT_COLOR;
        _commaLabel.textAlignment = NSTextAlignmentCenter;
        _commaLabel.backgroundColor = [UIColor clearColor];
        _commaLabel.text = @":";
        [self.contentView addSubview:_commaLabel];
        
        _hoursTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _hoursTextField.font = [UIFont fontWithName:IQ_HELVETICA size:15];
        _hoursTextField.textColor = TEXT_COLOR;
        _hoursTextField.textAlignment = NSTextAlignmentRight;
        _hoursTextField.backgroundColor = [UIColor clearColor];
        _hoursTextField.returnKeyType = UIReturnKeyNext;
        _hoursTextField.keyboardType = UIKeyboardTypeDecimalPad;
        [_hoursTextField setPlaceholder:NSLocalizedString(@"HH", nil)];
        _hoursTextField.delegate = self;
        [self.contentView addSubview:_hoursTextField];
        
        _minutesTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        [_minutesTextField setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
        [_minutesTextField setTextColor:TEXT_COLOR];
        _minutesTextField.textAlignment = NSTextAlignmentLeft;
        _minutesTextField.backgroundColor = [UIColor clearColor];
        _minutesTextField.returnKeyType = UIReturnKeyDone;
        _minutesTextField.keyboardType = UIKeyboardTypeDecimalPad;
        _minutesTextField.delegate = self;

        [_minutesTextField setPlaceholder:NSLocalizedString(@"MM", nil)];
        [self.contentView addSubview:_minutesTextField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    
    CGSize labelSize = [_label sizeThatFits:CGSizeMake(actualBounds.size.width, CGFLOAT_MAX)];
    CGSize commaSize = [_commaLabel sizeThatFits:CGSizeMake(actualBounds.size.width, CGFLOAT_MAX)];
    
    NSString *currentText = _hoursTextField.text;
    
    [_hoursTextField setText:@"0000"];
    CGSize hoursSize = [_hoursTextField sizeThatFits:CGSizeMake(actualBounds.size.width, CGFLOAT_MAX)];
    
    _hoursTextField.text = currentText;
    
    _label.frame = CGRectMake(actualBounds.origin.x,
                              actualBounds.origin.y + (actualBounds.size.height - labelSize.height) / 2.0f,
                              labelSize.width,
                              labelSize.height);
    
    _hoursTextField.frame = CGRectMake(_label.frame.origin.x + _label.bounds.size.width + HOURS_INSET,
                                      actualBounds.origin.y,
                                      hoursSize.width + HOURS_WIDHT_ADDITION,
                                      actualBounds.size.height);
    
    _commaLabel.frame = CGRectMake(_hoursTextField.frame.origin.x + _hoursTextField.bounds.size.width + COMMA_INSET,
                                   actualBounds.origin.y + (actualBounds.size.height - commaSize.height) / 2.0f,
                                   commaSize.width,
                                   commaSize.height);
    
    _minutesTextField.frame = CGRectMake(_commaLabel.frame.origin.x + _commaLabel.bounds.size.width + COMMA_INSET,
                                        actualBounds.origin.y,
                                        actualBounds.size.width - _commaLabel.frame.origin.x,
                                        actualBounds.size.height);
}

- (CGFloat)heightForWidth:(CGFloat)width {
    CGFloat actualWidht = width - CONTENT_HORIZONTAL_INSETS;
    CGFloat height = CONTENT_VERTICAL_INSETS * 2.0f;
    
    
    CGSize labelSize = [_label sizeThatFits:CGSizeMake(actualWidht, CGFLOAT_MAX)];
    CGSize hoursSize = [_hoursTextField sizeThatFits:CGSizeMake(actualWidht, CGFLOAT_MAX)];
    CGSize minutesSize = [_minutesTextField sizeThatFits:CGSizeMake(actualWidht, CGFLOAT_MAX)];
    
    height += MAX(labelSize.height, MAX(minutesSize.height, hoursSize.height));
    return MAX(height, CELL_MIN_HEIGHT);
}

- (void)setItem:(IQTaskEstimatedTimeItem *)item {
    _hoursTextField.text = item.hours;
    _minutesTextField.text = item.minutes;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(estimatedTimeCell:textFieldShouldBeginEditing:)]) {
            return [_delegate estimatedTimeCell:self textFieldShouldBeginEditing:textField];
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(estimatedTimeCell:textFieldDidBeginEditing:)]) {
            [_delegate estimatedTimeCell:self textFieldDidBeginEditing:textField];
        }
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(estimatedTimeCell:textFieldShouldEndEditing:)]) {
            return [_delegate estimatedTimeCell:self textFieldShouldEndEditing:textField];
        }
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(estimatedTimeCell:textFieldDidEndEditing:)]) {
            [_delegate estimatedTimeCell:self textFieldDidEndEditing:textField];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(estimatedTimeCell:textField:shouldChangeCharactersInRange:replacementString:)]) {
            return [_delegate estimatedTimeCell:self textField:textField shouldChangeCharactersInRange:range replacementString:string];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(estimatedTimeCell:textFieldShouldClear:)]) {
            return [_delegate estimatedTimeCell:self textFieldShouldClear:textField];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(estimatedTimeCell:textFieldShouldReturn:)]) {
            return [_delegate estimatedTimeCell:self textFieldShouldReturn:textField];
        }
    }
    return YES;
}




@end
