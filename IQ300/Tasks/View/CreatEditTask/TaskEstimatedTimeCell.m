//
//  TaskEstimatedTimeCell.m
//  IQ300
//
//  Created by Vladislav Grigoryev on 29/02/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "TaskEstimatedTimeCell.h"
#import "IQDetailsTextCell.h"

#define COMMA_INSET 2.0f
#define HOURS_INSET 0.0f
#define HOURS_WIDHT_ADDITION 10.0f

@interface TaskEstimatedTimeCell () {
    UIEdgeInsets _contentInsets;
}

@end

@implementation TaskEstimatedTimeCell

+ (CGFloat)heightForItem:(id)item detailTitle:(NSString*)detailTitle width:(CGFloat)width {
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
        [self.contentView addSubview:_hoursTextField];
        
        _minutesTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        [_minutesTextField setFont:[UIFont fontWithName:IQ_HELVETICA size:15]];
        [_minutesTextField setTextColor:TEXT_COLOR];
        _minutesTextField.textAlignment = NSTextAlignmentLeft;
        _minutesTextField.backgroundColor = [UIColor clearColor];
        _minutesTextField.returnKeyType = UIReturnKeyDone;
        _minutesTextField.keyboardType = UIKeyboardTypeDecimalPad;

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

- (void)setItem:(NSNumber *)item {
    if (item && [item isKindOfClass:[NSNumber class]]) {
        NSUInteger seconds = item.unsignedIntegerValue;
        
        NSUInteger hours = (NSUInteger)(seconds / 3600);
        NSUInteger minutes = (NSUInteger)(seconds - hours * 3600) / 60;
        
        _hoursTextField.text = [NSString stringWithFormat:(hours < 10 ? @"0%i" : @"%i"), hours];
        _minutesTextField.text = [NSString stringWithFormat:(minutes < 10 ? @"0%i" : @"%i"), minutes];
    }
}


@end
