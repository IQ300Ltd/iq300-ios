//
//  RegistrationStatusView.m
//  IQ300
//
//  Created by Tayphoon on 17.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "RegistrationStatusView.h"

#define LOGO_IMAGE_SIZE CGSizeMake(70, 45)
#define LOGIN_WIDTH 450.0f

@interface RegistrationStatusView() {
    UIEdgeInsets _contentInsets;
}

@end

@implementation RegistrationStatusView

+ (CGFloat)heightForText:(NSAttributedString*)text width:(CGFloat)textWidth {
    UITextView * titleTextView = [[UITextView alloc] init];
    titleTextView.textAlignment = NSTextAlignmentLeft;
    titleTextView.backgroundColor = [UIColor clearColor];
    titleTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    titleTextView.textContainerInset = UIEdgeInsetsZero;
    titleTextView.contentInset = UIEdgeInsetsZero;
    titleTextView.scrollEnabled = NO;
    titleTextView.attributedText = text;
    [titleTextView sizeToFit];
    
    CGFloat textHeight = [titleTextView sizeThatFits:CGSizeMake(textWidth, CGFLOAT_MAX)].height;
    return textHeight;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];

        _contentInsets = UIEdgeInsetsHorizontalMake(10.0f);
        
        _logoImageView = [[UIImageView alloc] init];
        [_logoImageView setImage:[UIImage imageNamed:@"login_logo.png"]];
        [self addSubview:_logoImageView];

        _statusTextView = [[IQTextView alloc] init];
        [_statusTextView setFont:[UIFont fontWithName:IQ_HELVETICA
                                               size:(IS_IPAD) ? 16.0f : 15.0f]];
        [_statusTextView setTextColor:IQ_FONT_BLACK_COLOR];
        _statusTextView.textAlignment = NSTextAlignmentCenter;
        _statusTextView.backgroundColor = [UIColor clearColor];
        _statusTextView.editable = NO;
        _statusTextView.textContainerInset = UIEdgeInsetsZero;
        _statusTextView.scrollEnabled = NO;
        _statusTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        [self addSubview:_statusTextView];

        _backButton = [[ExtendedButton alloc] init];
        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [_backButton setBackgroundColor:IQ_CELADON_COLOR];
        [_backButton setBackgroundColor:IQ_CELADON_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
        [_backButton setBackgroundColor:IQ_CELADON_COLOR_DISABLED forState:UIControlStateDisabled];
        [_backButton.layer setCornerRadius:2.0f];
        [_backButton setTitle:NSLocalizedString(@"Return to main screen", nil) forState:UIControlStateNormal];
        [_backButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
        [self addSubview:_backButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGSize logoSize = LOGO_IMAGE_SIZE;
    
#ifdef IPAD
    bounds = CGRectMake((self.bounds.size.width - LOGIN_WIDTH) / 2.0f,
                        100.0f,
                        LOGIN_WIDTH,
                        self.bounds.size.height);
#endif
    
    CGRect actualBounds = UIEdgeInsetsInsetRect(bounds, _contentInsets);
    
    _logoImageView.frame = CGRectMake(actualBounds.origin.x + (actualBounds.size.width - logoSize.width) / 2.0f,
                                      actualBounds.origin.y + 28.0f,
                                      logoSize.width,
                                      logoSize.height);
    
    CGFloat statusHeight = [RegistrationStatusView heightForText:_statusTextView.attributedText
                                                           width:actualBounds.size.width];

    _statusTextView.frame = CGRectMake(actualBounds.origin.x,
                                       CGRectBottom(_logoImageView.frame) + 44.0f,
                                       actualBounds.size.width,
                                       statusHeight + 40.0f);
    
    CGFloat buttonWidth = (IS_IPAD) ? 300.0f : actualBounds.size.width;
    _backButton.frame = CGRectMake(bounds.origin.x + (bounds.size.width - buttonWidth) / 2.0f,
                                   CGRectBottom(_statusTextView.frame) + 34.0f,
                                   buttonWidth,
                                   40.0f);
}

@end
