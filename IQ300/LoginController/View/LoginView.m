//
//  LoginView.m
//  IQ300
//
//  Created by Tayphoon on 17.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "LoginView.h"
#import "BottomLineView.h"

#define LOGO_IMAGE_SIZE CGSizeMake(70, 30)
#define LABEL_HEIGHT 25.0f
#define LOGIN_WIDTH 450.0f

@interface LoginView() {
    BottomLineView * _emailContainer;
    BottomLineView * _passwordContainer;
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
        
        _emailTextField = [[ExTextField alloc] init];
        _emailTextField.tag = 0;
        _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailContainer = [self makeContainerWithField:_emailTextField placeholder:@"Email"];
        [self addSubview:_emailContainer];
    
        _passwordTextField = [[ExTextField alloc] init];
        _passwordTextField.tag = 1;
        _passwordContainer = [self makeContainerWithField:_passwordTextField placeholder:@"Password"];
        _passwordTextField.secureTextEntry = YES;
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
        
        _restorePassButton = [[UIButton alloc] init];
        [_restorePassButton setTitle:NSLocalizedString(@"Forgot your password?", nil) forState:UIControlStateNormal];
        [_restorePassButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:(IS_IPAD) ? 13.0f : 12.0f]];
        [_restorePassButton setTitleColor:[UIColor colorWithHexInt:0x358bae] forState:UIControlStateNormal];
        [self addSubview:_restorePassButton];
        
        _registryButton = [[UIButton alloc] init];
        [_registryButton setTitle:NSLocalizedString(@"Registry", nil) forState:UIControlStateNormal];
        [_registryButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:(IS_IPAD) ? 13.0f : 12.0f]];
        [_registryButton setTitleColor:[UIColor colorWithHexInt:0x358bae] forState:UIControlStateNormal];
        [self addSubview:_registryButton];
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
    
    _logoImageView.frame = CGRectMake((self.bounds.size.width - logoSize.width) / 2.0f,
                                      bounds.origin.y + 28,
                                      logoSize.width,
                                      logoSize.height);
   
    CGRect fieldsRect = UIEdgeInsetsInsetRect(bounds, _fieldsInsets);
    
    _emailContainer.frame = CGRectMake(fieldsRect.origin.x,
                                       _logoImageView.frame.origin.y + _logoImageView.frame.size.height + 44,
                                       fieldsRect.size.width,
                                       LABEL_HEIGHT);
    
    _passwordContainer.frame = CGRectMake(fieldsRect.origin.x,
                                          _emailContainer.frame.origin.y + _emailContainer.frame.size.height + 18,
                                          fieldsRect.size.width,
                                          LABEL_HEIGHT);
    
    _errorLabel.frame = CGRectMake(fieldsRect.origin.x,
                                   _passwordContainer.frame.origin.y + _passwordContainer.frame.size.height + 8,
                                   fieldsRect.size.width,
                                   LABEL_HEIGHT);
    
    CGFloat horizontalOffset = 10.0f;
    _enterButton.frame = CGRectMake(bounds.origin.x + horizontalOffset,
                                    _passwordContainer.frame.origin.y + _passwordContainer.frame.size.height + 42,
                                    bounds.size.width - horizontalOffset * 2.0f,
                                    40);
    
    CGFloat labelsSize = (IS_IPAD) ? 11 : 10;
    _restorePassButton.frame = CGRectMake(bounds.origin.x,
                                          _enterButton.frame.origin.y + _enterButton.frame.size.height + 34,
                                          bounds.size.width,
                                          labelsSize);
    
    _registryButton.frame = CGRectMake(bounds.origin.x,
                                       _restorePassButton.frame.origin.y + _restorePassButton.frame.size.height + 30,
                                       bounds.size.width,
                                       labelsSize);
}

- (BottomLineView*)makeContainerWithField:(ExTextField*)textField placeholder:(NSString*)placeholder {
    BottomLineView * containerView = [[BottomLineView alloc] init];
    containerView.bottomLineColor = [UIColor colorWithHexInt:0xc8c9c9];
    containerView.bottomLineHeight = 0.5f;
    [containerView setBackgroundColor:[UIColor clearColor]];
    
    textField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    textField.font = [UIFont fontWithName:IQ_HELVETICA size:16];
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(placeholder, nil)
                                                                      attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexInt:0xb6b6b6]}];

    [containerView addSubview:textField];
    return containerView;
}

@end
