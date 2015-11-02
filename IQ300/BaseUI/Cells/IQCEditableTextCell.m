//
//  IQCEditableTextCell.m
//  IQ300
//
//  Created by Tayphoon on 21.07.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQCEditableTextCell.h"

const CGFloat ClearButtonHeight = 26;

@implementation IQCEditableTextCell

+ (CGFloat)heightForItem:(id)item detailTitle:(NSString*)detailTitle width:(CGFloat)width {
    NSString * text = ([item isKindOfClass:[NSString class]]) ? item : detailTitle;
    
    CGFloat textWidth = width - ClearButtonHeight * 0.5f - CONTENT_HORIZONTAL_INSETS * 2.0f;
    CGFloat height = CONTENT_VERTICAL_INSETS * 2.0f;
    
    UITextView * titleTextView = [[UITextView alloc] init];
    [titleTextView setFont:TEXT_FONT];
    titleTextView.textAlignment = NSTextAlignmentLeft;
    titleTextView.backgroundColor = [UIColor clearColor];
    titleTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    titleTextView.textContainerInset = UIEdgeInsetsZero;
    titleTextView.contentInset = UIEdgeInsetsZero;
    titleTextView.scrollEnabled = NO;
    titleTextView.text = text;
    [titleTextView sizeToFit];
    
    CGFloat titleHeight = [titleTextView sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height;
    height += titleHeight;
    
    return MAX(height, CELL_MIN_HEIGHT);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _clearTextViewButton = [[UIButton alloc] init];
        [_clearTextViewButton setImage:[UIImage imageNamed:@"clear_button_icon.png"] forState:UIControlStateNormal];
        [_clearTextViewButton setFrame:CGRectMake(0, 0, ClearButtonHeight, ClearButtonHeight)];
        [_clearTextViewButton setHidden:YES];
        [self.contentView addSubview:_clearTextViewButton];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    
    CGFloat titleWidth = actualBounds.size.width - ClearButtonHeight * 0.5f;
    CGFloat titleHeight = [self.titleTextView sizeThatFits:CGSizeMake(titleWidth, CGFLOAT_MAX)].height;
    
    self.titleTextView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y + (actualBounds.size.height - titleHeight) / 2.0f,
                                      titleWidth,
                                      titleHeight);

    if (_clearButtonEnabled) {
        _clearTextViewButton.frame = CGRectMake(CGRectRight(self.titleTextView.frame),
                                                 self.titleTextView.frame.origin.y + (self.titleTextView.frame.size.height - ClearButtonHeight) / 2.0f,
                                                 ClearButtonHeight,
                                                 ClearButtonHeight);
    }
    else {
        _clearTextViewButton.frame = CGRectZero;
    }
}

- (void)setItem:(id)item {
    [super setItem:item];
    
    if (_clearButtonEnabled) {
        _clearTextViewButton.hidden = (self.titleTextView.text.length == 0);
    }
}

- (void)setClearButtonEnabled:(BOOL)clearButtonEnabled {
    if (_clearButtonEnabled != clearButtonEnabled) {
        _clearButtonEnabled = clearButtonEnabled;
        
        [self setNeedsLayout];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_clearTextViewButton removeTarget:nil
                                 action:NULL
                       forControlEvents:UIControlEventTouchUpInside];
}

@end
