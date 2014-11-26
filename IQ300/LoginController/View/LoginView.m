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

@interface LoginView() {
    BottomLineView * _emailContainer;
    BottomLineView * _passwordContainer;
}

@end

@implementation LoginView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithHexInt:0xf1f5f6]];
        
        _logoImageView = [[UIImageView alloc] init];
        [_logoImageView setImage:[UIImage imageNamed:@"login_logo.png"]];
        [self addSubview:_logoImageView];
        
        _emailTextField = [[ExTextField alloc] init];
        _emailContainer = [self makeContainerWithField:_emailTextField placeholder:@"Email"];
        [self addSubview:_emailContainer];
    
        _passwordTextField = [[ExTextField alloc] init];
        _passwordContainer = [self makeContainerWithField:_passwordTextField placeholder:@"Password"];
        _passwordTextField.secureTextEntry = YES;
        [self addSubview:_passwordContainer];
        
        _errorLabel = [[UILabel alloc] init];
        [_errorLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:13]];
        [_errorLabel setTextColor:[UIColor colorWithHexInt:0xca301e]];
        _errorLabel.textAlignment = NSTextAlignmentLeft;
        _errorLabel.backgroundColor = [UIColor clearColor];
        _errorLabel.numberOfLines = 0;
        _errorLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:_errorLabel];
        
        _enterButton = [[UIButton alloc] init];
        [_enterButton setBackgroundColor:[UIColor colorWithHexInt:0x348dad]];
        [_enterButton.layer setCornerRadius:2.0f];
        [_enterButton setTitle:NSLocalizedString(@"Enter", nil) forState:UIControlStateNormal];
        [_enterButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
        [self addSubview:_enterButton];
        
        _restorePassButton = [[UIButton alloc] init];
        [_restorePassButton setTitle:NSLocalizedString(@"Forgot your password?", nil) forState:UIControlStateNormal];
        [_restorePassButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:12]];
        [_restorePassButton setTitleColor:[UIColor colorWithHexInt:0x358bae] forState:UIControlStateNormal];
        [self addSubview:_restorePassButton];
        
        _registryButton = [[UIButton alloc] init];
        [_registryButton setTitle:NSLocalizedString(@"Registry", nil) forState:UIControlStateNormal];
        [_registryButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:12]];
        [_registryButton setTitleColor:[UIColor colorWithHexInt:0x358bae] forState:UIControlStateNormal];
        [self addSubview:_registryButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize logoSize = LOGO_IMAGE_SIZE;
    _logoImageView.frame = CGRectMake((self.bounds.size.width - logoSize.width) / 2,
                                      28,
                                      logoSize.width,
                                      logoSize.height);
    
    _emailContainer.frame = CGRectMake(0,
                                       _logoImageView.frame.origin.y + _logoImageView.frame.size.height + 44,
                                       self.bounds.size.width,
                                       LABEL_HEIGHT);
    
    _passwordContainer.frame = CGRectMake(0,
                                          _emailContainer.frame.origin.y + _emailContainer.frame.size.height + 18,
                                          self.bounds.size.width,
                                          LABEL_HEIGHT);
    
    _errorLabel.frame = CGRectMake(10,
                                   _passwordContainer.frame.origin.y + _passwordContainer.frame.size.height + 8,
                                   self.bounds.size.width,
                                   20);
    
    CGFloat horizontalOffset = 10.0f;
    _enterButton.frame = CGRectMake(horizontalOffset,
                                    _passwordContainer.frame.origin.y + _passwordContainer.frame.size.height + 42,
                                    self.bounds.size.width - horizontalOffset * 2.0f,
                                    40);
    
    _restorePassButton.frame = CGRectMake(0.0f,
                                          _enterButton.frame.origin.y + _enterButton.frame.size.height + 34,
                                          self.bounds.size.width,
                                          10);
    
    _registryButton.frame = CGRectMake(0.0f,
                                          _restorePassButton.frame.origin.y + _restorePassButton.frame.size.height + 30,
                                          self.bounds.size.width,
                                          10);
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
    [textField setPlaceholderInsets:UIEdgeInsetsMake(0, 10, 1, 0)];
    [textField setTextInsets:UIEdgeInsetsMake(0, 10, 1, 0)];

    [containerView addSubview:textField];
    return containerView;
}

@end
