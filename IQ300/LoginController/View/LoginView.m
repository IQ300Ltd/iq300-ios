//
//  LoginView.m
//  IQ300
//
//  Created by Tayphoon on 17.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "LoginView.h"
#import "BottomLineView.h"
#import "IQTextContainer.h"

#define LOGO_IMAGE_SIZE CGSizeMake(70, 30)
#define LABEL_HEIGHT 25.0f
#define LOGIN_WIDTH 450.0f

@interface LoginView() {
    IQTextContainer * _emailContainer;
    IQTextContainer * _passwordContainer;
    UIEdgeInsets _fieldsInsets;
}

@end

@implementation LoginView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        _fieldsInsets = UIEdgeInsetsMake(0, 12, 0, 12);
        
        _logoImageView = [[UIImageView alloc] init];
        [_logoImageView setImage:[UIImage imageNamed:@"login_logo.png"]];
        [self addSubview:_logoImageView];
        
        _emailContainer = [[IQTextContainer alloc] init];
        _emailContainer.textField.tag = 0;
        _emailContainer.textField.keyboardType = UIKeyboardTypeEmailAddress;
        [_emailContainer setLocalizedPlaceholder:@"Email"];
        [self addSubview:_emailContainer];
    
        _passwordContainer = [[IQTextContainer alloc] init];
        _passwordContainer.textField.tag = 1;
        _passwordContainer.textField.secureTextEntry = YES;
        [_passwordContainer setLocalizedPlaceholder:@"Password"];
        [self addSubview:_passwordContainer];
        
        _errorLabel = [[UILabel alloc] init];
        [_errorLabel setFont:[UIFont fontWithName:IQ_HELVETICA
                                             size:(IS_IPAD) ? 14.0f : 13.0f]];
        [_errorLabel setTextColor:[UIColor colorWithHexInt:0xca301e]];
        _errorLabel.textAlignment = NSTextAlignmentLeft;
        _errorLabel.backgroundColor = [UIColor clearColor];
        _errorLabel.numberOfLines = 0;
        _errorLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_errorLabel];
        
        _enterButton = [[ExtendedButton alloc] init];
        [_enterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [_enterButton setBackgroundColor:IQ_CELADON_COLOR];
        [_enterButton setBackgroundColor:IQ_CELADON_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
        [_enterButton setBackgroundColor:IQ_CELADON_COLOR_DISABLED forState:UIControlStateDisabled];
        [_enterButton.layer setCornerRadius:2.0f];
        [_enterButton setTitle:NSLocalizedString(@"Enter", nil) forState:UIControlStateNormal];
        [_enterButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
        [self addSubview:_enterButton];
        
        _registryButton = [[ExtendedButton alloc] init];
        [_registryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [_registryButton setBackgroundColor:IQ_CELADON_COLOR];
        [_registryButton setBackgroundColor:IQ_CELADON_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
        [_enterButton setBackgroundColor:IQ_CELADON_COLOR_DISABLED forState:UIControlStateDisabled];
        [_registryButton.layer setCornerRadius:2.0f];
        [_registryButton setTitle:NSLocalizedString(@"Sign up", nil) forState:UIControlStateNormal];
        [_registryButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
        [self addSubview:_registryButton];
    }
    return self;
}

- (ExTextField*)emailTextField {
    return _emailContainer.textField;
}

- (ExTextField*)passwordTextField {
    return _passwordContainer.textField;
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
    
    _logoImageView.frame = CGRectMake((self.bounds.size.width - logoSize.width) / 2.0f,
                                      bounds.origin.y + 28,
                                      logoSize.width,
                                      logoSize.height);
   
    CGRect fieldsRect = UIEdgeInsetsInsetRect(bounds, _fieldsInsets);
    
    _emailContainer.frame = CGRectMake(fieldsRect.origin.x,
                                      CGRectBottom(_logoImageView.frame) + 44,
                                       fieldsRect.size.width,
                                       LABEL_HEIGHT);
    
    _passwordContainer.frame = CGRectMake(fieldsRect.origin.x,
                                          CGRectBottom(_emailContainer.frame) + 18,
                                          fieldsRect.size.width,
                                          LABEL_HEIGHT);
    
    _errorLabel.frame = CGRectMake(fieldsRect.origin.x,
                                   CGRectBottom(_passwordContainer.frame) + 8,
                                   fieldsRect.size.width,
                                   LABEL_HEIGHT);
    
    CGFloat horizontalOffset = 10.0f;
    _enterButton.frame = CGRectMake(bounds.origin.x + horizontalOffset,
                                    CGRectBottom(_passwordContainer.frame) + 42,
                                    bounds.size.width - horizontalOffset * 2.0f,
                                    40);
    
    _registryButton.frame = CGRectMake(bounds.origin.x + horizontalOffset,
                                       CGRectBottom(_enterButton.frame) + 20,
                                       bounds.size.width - horizontalOffset * 2.0f,
                                       40);
}

@end
