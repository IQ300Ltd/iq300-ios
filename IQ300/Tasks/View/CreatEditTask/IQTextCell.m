//
//  IQTextCell.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 10/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQTextCell.h"
#import "IQTextItem.h"

#define SELECTED_TEXT_COLOR [UIColor colorWithHexInt:0x9f9f9f]
#define ACCESSORY_VIEW_SIZE 17.0f
#define TITLE_OFFSET 10.0f

@interface IQTextCell () <UITextViewDelegate>

@end

@implementation IQTextCell

+ (CGFloat)heightForItem:(IQTextItem *)item width:(CGFloat)width {
    CGFloat textWidth = width - CONTENT_HORIZONTAL_INSETS * 2.0f - ACCESSORY_VIEW_SIZE - TITLE_OFFSET;
    CGFloat height = CONTENT_VERTICAL_INSETS * 2.0f;
    
    PlaceholderTextView * titleTextView = [[PlaceholderTextView alloc] init];
    [titleTextView setFont:TEXT_FONT];
    titleTextView.textAlignment = NSTextAlignmentLeft;
    titleTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    titleTextView.textContainerInset = UIEdgeInsetsZero;
    titleTextView.contentInset = UIEdgeInsetsZero;
    titleTextView.scrollEnabled = NO;
    titleTextView.placeholderInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f);
    
    titleTextView.placeholder = item.placeholder;
    titleTextView.text = item.text;
    [titleTextView sizeToFit];
    
    CGFloat titleHeight = [titleTextView sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height;
    height += titleHeight;
    
    return MAX(height, CELL_MIN_HEIGHT);
}

- (CGFloat)heightForWidth:(CGFloat)width {
    CGFloat height = _contentInsets.top + _contentInsets.bottom;
    CGFloat textWidth = width - _contentInsets.left - _contentInsets.right - ACCESSORY_VIEW_SIZE - TITLE_OFFSET;
    CGFloat titleHeight = [_textView sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height;
    height += titleHeight;
    
    return MAX(height, CELL_MIN_HEIGHT);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _contentInsets = UIEdgeInsetsMake(CONTENT_VERTICAL_INSETS,
                                          CONTENT_HORIZONTAL_INSETS,
                                          CONTENT_VERTICAL_INSETS,
                                          CONTENT_HORIZONTAL_INSETS);
        
        self.backgroundColor = [UIColor whiteColor];
        super.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        _textView = [[PlaceholderTextView alloc] init];
        [_textView setFont:TEXT_FONT];
        [_textView setTextColor:TEXT_COLOR];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        _textView.textContainerInset = UIEdgeInsetsZero;
        _textView.contentInset = UIEdgeInsetsZero;
        _textView.scrollEnabled = NO;
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.placeholderInsets = UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f);
        _textView.delegate = self;
        [self.contentView addSubview:_textView];
        
        _accessoryImageView = [[UIImageView alloc] init];
        _accessoryImageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_accessoryImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.contentView.bounds;
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    
    CGSize accessorySize = CGSizeMake(ACCESSORY_VIEW_SIZE, ACCESSORY_VIEW_SIZE);
    _accessoryImageView.frame = CGRectMake(actualBounds.origin.x + actualBounds.size.width - accessorySize.width,
                                           actualBounds.origin.y + (actualBounds.size.height - accessorySize.height) / 2.0f,
                                           accessorySize.width,
                                           accessorySize.height);
    
    
    CGFloat titleWidth = actualBounds.size.width - ACCESSORY_VIEW_SIZE - TITLE_OFFSET;
    CGFloat titleHeight = [_textView sizeThatFits:CGSizeMake(titleWidth, CGFLOAT_MAX)].height;
    
    _textView.frame = CGRectMake(actualBounds.origin.x,
                                          actualBounds.origin.y + (actualBounds.size.height - titleHeight) / 2.0f,
                                          titleWidth,
                                          titleHeight);

}

- (void)setItem:(IQTextItem *)item {
    _textView.text = item.text;
    _textView.placeholder = item.placeholder;
    _accessoryImageView.image = [UIImage imageNamed:item.accessoryImageName];
    _textView.userInteractionEnabled = [item editable];
    _textView.returnKeyType = item.returnKeyType;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _textView.text = nil;
    _textView.textColor = TEXT_COLOR;
    _textView.placeholder = nil;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(textCell:textViewShouldBeginEditing:)]) {
            return [_delegate textCell:self textViewShouldBeginEditing:textView];
        }
    }
    return NO;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(textCell:textViewShouldEndEditing:)]) {
            return [_delegate textCell:self textViewShouldEndEditing:textView];
        }
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(textCell:textViewDidBeginEditing:)]) {
            return [_delegate textCell:self textViewDidBeginEditing:textView];
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(textCell:textViewDidEndEditing:)]) {
            return [_delegate textCell:self textViewDidEndEditing:textView];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(textCell:textView:shouldChangeTextInRange:replacementText:)]) {
            return [_delegate textCell:self textView:textView shouldChangeTextInRange:range replacementText:text];
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(textCell:textViewDidChange:)]) {
            return [_delegate textCell:self textViewDidChange:textView];
        }
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(textCell:textViewDidChangeSelection:)]) {
            return [_delegate textCell:self textViewDidChangeSelection:textView];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(textCell:textView:shouldInteractWithURL:inRange:)]) {
            return [_delegate textCell:self textView:textView shouldInteractWithURL:URL inRange:characterRange];
        }
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(textCell:textView:shouldInteractWithTextAttachment:inRange:)]) {
            return [_delegate textCell:self textView:textView shouldInteractWithTextAttachment:textAttachment inRange:characterRange];
        }
    }
    return YES;
}



@end
