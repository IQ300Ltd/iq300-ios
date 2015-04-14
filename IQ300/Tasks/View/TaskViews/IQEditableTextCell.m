//
//  IQEditableTextCell.m
//  IQ300
//
//  Created by Tayphoon on 14.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQEditableTextCell.h"

@implementation IQEditableTextCell

+ (CGFloat)heightForItem:(NSString*)text width:(CGFloat)width {
    CGFloat textWidth = width - CONTENT_HORIZONTAL_INSETS * 2.0f;
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
    
    return MAX(height, 50.0f);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        
        _contentInsets = UIEdgeInsetsMake(CONTENT_VERTICAL_INSETS,
                                          CONTENT_HORIZONTAL_INSETS,
                                          CONTENT_VERTICAL_INSETS,
                                          CONTENT_HORIZONTAL_INSETS);
        
        self.backgroundColor = [UIColor whiteColor];
        super.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        _titleTextView = [[PlaceholderTextView alloc] init];
        [_titleTextView setFont:TEXT_FONT];
        [_titleTextView setTextColor:TEXT_COLOR];
        _titleTextView.textAlignment = NSTextAlignmentLeft;
        _titleTextView.backgroundColor = [UIColor clearColor];
        _titleTextView.editable = NO;
        _titleTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        _titleTextView.textContainerInset = UIEdgeInsetsZero;
        _titleTextView.contentInset = UIEdgeInsetsZero;
        _titleTextView.scrollEnabled = NO;
        _titleTextView.returnKeyType = UIReturnKeyDone;
        _titleTextView.placeholderInsets = UIEdgeInsetsMakeWithInset(5.0f);
        [self.contentView addSubview:_titleTextView];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    
    CGFloat titleHeight = [_titleTextView sizeThatFits:CGSizeMake(actualBounds.size.width, CGFLOAT_MAX)].height;
    
    _titleTextView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y + (actualBounds.size.height - titleHeight) / 2.0f,
                                      actualBounds.size.width,
                                      titleHeight);
}

@end
