//
//  PlaceholderTextView.m
//  IQ300
//
//  Created by Tayphoon on 23.12.11.
//  Copyright (c) 2011 Tayphoon. All rights reserved.
//
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define is_iOS7 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")
#define is_iOS8 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")

#import "PlaceholderTextView.h"

@interface PlaceholderTextView (){
	BOOL _drawPlaceholder;
    BOOL _settingText;
}

@end

@implementation PlaceholderTextView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleTextViewDidChangeNotification:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleTextViewDidChangeNotification:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
        [self initialize];
    }
    return self;
}

- (void)setText:(NSString *)string {
    _settingText = YES;
	[super setText:string];
    _settingText = NO;
	[self updatePlaceholderIfNeed];
}

- (void)setPlaceholder:(NSString *)string {
	if ([string isEqual:_placeholder]) {
		return;
	}
    
	_placeholder = string;
	
	[self updatePlaceholderIfNeed];
}

- (UIFont*)placeholderFont {
    if (_placeholderFont == nil) {
        _placeholderFont = self.font;
    }

    return _placeholderFont;
}

#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	if (_drawPlaceholder) {
        
        NSDictionary * attributes = @{ NSFontAttributeName : self.placeholderFont,
                                       NSForegroundColorAttributeName : self.placeholderColor};
        
        CGRect placeholderRect = UIEdgeInsetsInsetRect(rect, _placeholderInsets);
        [self.placeholder drawInRect:placeholderRect withAttributes:attributes];
	}
}

- (CGSize)sizeThatFits:(CGSize)size {
    if(_drawPlaceholder && [self.text length] == 0) {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary * attributes = @{ NSFontAttributeName : self.placeholderFont,
                                       NSParagraphStyleAttributeName : paragraphStyle};
        
        CGSize resultSize = [self.placeholder boundingRectWithSize:size
                                                           options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                        attributes:attributes
                                                           context:nil].size;
        return CGSizeMake(resultSize.width + _placeholderInsets.left + _placeholderInsets.right,
                          resultSize.height + _placeholderInsets.top + _placeholderInsets.bottom);
    }
    
    return [super sizeThatFits:size];
}

#pragma mark - Private

- (void)initialize {
	self.placeholderColor = [UIColor colorWithWhite:0.702f alpha:1.0f];
	_drawPlaceholder = NO;
    _placeholderInsets = UIEdgeInsetsMake(2, 8, 2, 2);
}

- (void)updatePlaceholderIfNeed {
	BOOL prev = _drawPlaceholder;
	_drawPlaceholder = self.placeholder && self.placeholderColor && self.text.length == 0;
	
	if (prev != _drawPlaceholder) {
		[self setNeedsDisplay];
	}
}

- (void)scrollToCaretInTextView:(UITextView *)textView animated:(BOOL)animated {
    CGRect rect = [textView caretRectForPosition:textView.selectedTextRange.end];
    rect.size.height += textView.textContainerInset.bottom;
    [textView scrollRectToVisible:rect animated:animated];
}

- (void)handleTextViewDidChangeNotification:(NSNotification *)notification {
    if (notification.object == self && is_iOS7 && !is_iOS8 && !_settingText) {
        UITextView *textView = self;
        if ([textView.text hasSuffix:@"\n"]) {
            [CATransaction setCompletionBlock:^{
                [self scrollToCaretInTextView:textView animated:NO];
            }];
        } else {
            [self scrollToCaretInTextView:textView animated:NO];
        }
    }
}

@end
