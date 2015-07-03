//
//  RegistrationView.m
//  IQ300
//
//  Created by Tayphoon on 17.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "RegistrationView.h"
#import "IQEmailValidator.h"
#import "IQPasswordValidator.h"

#define LOGO_IMAGE_SIZE CGSizeMake(70, 30)
#define LABEL_HEIGHT 25.0f
#define LOGIN_WIDTH 470.0f

@interface RegistrationView() {
    UIScrollView * _scrollView;
    UIEdgeInsets _fieldsInsets;
    CGFloat _scrollViewOffset;
}

@end

@implementation RegistrationView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        _fieldsInsets = UIEdgeInsetsMake(0, 12, 0, 12);
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        _logoImageView = [[UIImageView alloc] init];
        [_logoImageView setImage:[UIImage imageNamed:@"login_logo.png"]];
        [_scrollView addSubview:_logoImageView];
        
        IQStringValidator * stringValidator = [IQStringValidator validator];
        
        _nameContainer = [[IQTextContainer alloc] init];
        _nameContainer.tag = 1;
        _nameContainer.validator = stringValidator;
        _nameContainer.textField.keyboardType = UIKeyboardTypeEmailAddress;
        [_nameContainer setLocalizedPlaceholder:@"Name"];
        [_scrollView addSubview:_nameContainer];

        IQStringValidator * surnameValidator = [IQStringValidator validator];
        surnameValidator.errorDescription = NSLocalizedStringFromTable(@"%@ can not be emptys", @"IQValidatorLocalization", nil);
        
        _surnameContainer = [[IQTextContainer alloc] init];
        _surnameContainer.tag = 2;
        _surnameContainer.validator = surnameValidator;
        _surnameContainer.textField.keyboardType = UIKeyboardTypeEmailAddress;
        [_surnameContainer setLocalizedPlaceholder:@"Surname"];
        [_scrollView addSubview:_surnameContainer];

        _organizationContainer = [[IQTextContainer alloc] init];
        _organizationContainer.tag = 3;
        _organizationContainer.validator = stringValidator;
        [_organizationContainer setLocalizedPlaceholder:@"Organization name"];
        [_scrollView addSubview:_organizationContainer];

        IQEmailValidator * emailValidator = [IQEmailValidator validator];
        emailValidator.errorDescription = NSLocalizedStringFromTable(@"%@ can not be emptys", @"IQValidatorLocalization", nil);
        
        _emailContainer = [[IQTextContainer alloc] init];
        _emailContainer.tag = 4;
        _emailContainer.validator = emailValidator;
        _emailContainer.textField.keyboardType = UIKeyboardTypeEmailAddress;
        [_emailContainer setLocalizedPlaceholder:@"Email"];
        [_scrollView addSubview:_emailContainer];

        IQPasswordValidator * passwordValidator = [IQPasswordValidator validator];

        _passwordContainer = [[IQTextContainer alloc] init];
        _passwordContainer.tag = 5;
        _passwordContainer.validator = passwordValidator;
        _passwordContainer.textField.secureTextEntry = YES;
        [_passwordContainer setLocalizedPlaceholder:@"Password"];
        [_scrollView addSubview:_passwordContainer];
        
        _errorLabel = [[UILabel alloc] init];
        [_errorLabel setFont:[UIFont fontWithName:IQ_HELVETICA
                                             size:(IS_IPAD) ? 14.0f : 13.0f]];
        [_errorLabel setTextColor:[UIColor colorWithHexInt:0xca301e]];
        _errorLabel.textAlignment = NSTextAlignmentLeft;
        _errorLabel.backgroundColor = [UIColor clearColor];
        _errorLabel.numberOfLines = 0;
        _errorLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_scrollView addSubview:_errorLabel];

        _signupButton = [[ExtendedButton alloc] init];
        [_signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [_signupButton setBackgroundColor:IQ_CELADON_COLOR];
        [_signupButton setBackgroundColor:IQ_CELADON_COLOR_HIGHLIGHTED forState:UIControlStateHighlighted];
        [_signupButton setBackgroundColor:IQ_CELADON_COLOR_DISABLED forState:UIControlStateDisabled];
        [_signupButton.layer setCornerRadius:2.0f];
        [_signupButton setTitle:NSLocalizedString(@"Sign up", nil) forState:UIControlStateNormal];
        [_signupButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:16]];
        [_scrollView addSubview:_signupButton];
        
        _enterButton = [[UIButton alloc] init];
        [_enterButton setTitle:NSLocalizedString(@"Enter", nil) forState:UIControlStateNormal];
        [_enterButton.titleLabel setFont:[UIFont fontWithName:IQ_HELVETICA size:(IS_IPAD) ? 13.0f : 12.0f]];
        [_enterButton setTitleColor:[UIColor colorWithHexInt:0x358bae] forState:UIControlStateNormal];
        [_scrollView addSubview:_enterButton];

        _helpTextView = [[IQTextView alloc] init];
        [_helpTextView setFont:[UIFont fontWithName:IQ_HELVETICA
                                            size:(IS_IPAD) ? 16.0f : 15.0f]];
        [_helpTextView setTextColor:[UIColor colorWithHexInt:0x272727]];
        _helpTextView.textAlignment = NSTextAlignmentCenter;
        _helpTextView.backgroundColor = [UIColor clearColor];
        _helpTextView.editable = NO;
        _helpTextView.textContainerInset = UIEdgeInsetsZero;
        _helpTextView.scrollEnabled = NO;
        _helpTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        _helpTextView.linkTextAttributes = @{
                                          NSForegroundColorAttributeName: [UIColor colorWithHexInt:0x358bae],
                                          NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)
                                          };
        _helpTextView.text = NSLocalizedString(@"registration_help_message", nil);
        [_scrollView addSubview:_helpTextView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _scrollView.frame = self.bounds;

    CGRect bounds = _scrollView.bounds;
    CGSize logoSize = LOGO_IMAGE_SIZE;
    
#ifdef IPAD
    bounds = CGRectMake((_scrollView.bounds.size.width - LOGIN_WIDTH) / 2.0f,
                        100.0f,
                        LOGIN_WIDTH,
                        _scrollView.bounds.size.height);
#endif
    
    _logoImageView.frame = CGRectMake((self.bounds.size.width - logoSize.width) / 2.0f,
                                      bounds.origin.y + 28,
                                      logoSize.width,
                                      logoSize.height);
    
    CGRect fieldsRect = UIEdgeInsetsInsetRect(bounds, _fieldsInsets);
    CGFloat fieldsOffset = 18.0f;
    
    _nameContainer.frame = CGRectMake(fieldsRect.origin.x,
                                      CGRectBottom(_logoImageView.frame) + 44,
                                      fieldsRect.size.width,
                                      LABEL_HEIGHT);
    
    _surnameContainer.frame = CGRectMake(fieldsRect.origin.x,
                                         CGRectBottom(_nameContainer.frame) + fieldsOffset,
                                         fieldsRect.size.width,
                                         LABEL_HEIGHT);
    
    _organizationContainer.frame = CGRectMake(fieldsRect.origin.x,
                                              CGRectBottom(_surnameContainer.frame) + fieldsOffset,
                                              fieldsRect.size.width,
                                              LABEL_HEIGHT);
    
    _emailContainer.frame = CGRectMake(fieldsRect.origin.x,
                                       CGRectBottom(_organizationContainer.frame) + fieldsOffset,
                                       fieldsRect.size.width,
                                       LABEL_HEIGHT);
    
    _passwordContainer.frame = CGRectMake(fieldsRect.origin.x,
                                          CGRectBottom(_emailContainer.frame) + fieldsOffset,
                                          fieldsRect.size.width,
                                          LABEL_HEIGHT);
    
    CGSize constrainedSize = CGSizeMake(fieldsRect.size.width,
                                        100.0f);
    
    CGSize errorLabelSize = [_errorLabel.text sizeWithFont:_errorLabel.font
                                            constrainedToSize:constrainedSize
                                                lineBreakMode:NSLineBreakByWordWrapping];

    _errorLabel.frame = CGRectMake(fieldsRect.origin.x,
                                   CGRectBottom(_passwordContainer.frame) + 15,
                                   fieldsRect.size.width,
                                   errorLabelSize.height);
    
    CGFloat horizontalOffset = 10.0f;
    _signupButton.frame = CGRectMake(bounds.origin.x + horizontalOffset,
                                       CGRectBottom(_errorLabel.frame) + 20.0f,
                                       bounds.size.width - horizontalOffset * 2.0f,
                                       40);
    
    CGFloat labelsSize = (IS_IPAD) ? 15 : 14;
    _enterButton.frame = CGRectMake(bounds.origin.x,
                                    CGRectBottom(_signupButton.frame) + 34,
                                    bounds.size.width,
                                    labelsSize);
    
    _helpTextView.frame = CGRectMake(bounds.origin.x,
                                  CGRectBottom(_enterButton.frame) + 30,
                                  bounds.size.width,
                                  (IS_IPAD) ? 39 : 37);
    _scrollView.contentSize = CGSizeMake(bounds.size.width,
                                         CGRectBottom(_helpTextView.frame) + 20.0f);
}

- (void)setScrollViewOffset:(CGFloat)offset {
    _scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, offset, 0.0f);
}

- (void)scrollToFieldWithTag:(NSInteger)tag animated:(BOOL)animated {
    IQTextContainer * textField = [self fieldViewWithTag:tag];
    if (textField) {
        CGRect textFieldRect = [textField convertRect:textField.bounds toView:_scrollView];
        textFieldRect.origin.x = 0;
        textFieldRect.size.height = (IS_IPAD) ? 200 : 150;
        [_scrollView scrollRectToVisible:textFieldRect animated:animated];
    }
    else {
        _scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
    }
}

- (IQTextContainer*)fieldViewWithTag:(NSInteger)tag {
    for (UIView * view in _scrollView.subviews) {
        if ([view isKindOfClass:[IQTextContainer class]] && view.tag == tag) {
            return (IQTextContainer*)view;
        }
    }
    return nil;
}

- (void)setTextFieldDelegate:(id<UITextFieldDelegate>)delegate {
    for (UIView * view in _scrollView.subviews) {
        if ([view isKindOfClass:[IQTextContainer class]]) {
            ((IQTextContainer*)view).textField.delegate = delegate;
        }
    }
}

- (BOOL)validateFieldsWithError:(NSError**)error {
    NSError * validationError = nil;
    for (UIView * view in _scrollView.subviews) {
        if ([view isKindOfClass:[IQTextContainer class]]) {
            IQTextContainer * textContainer = (IQTextContainer*)view;
            [textContainer validateValue];
            
            if (!textContainer.isValid) {
                validationError = textContainer.validationError;
                if ([validationError.domain isEqualToString:IQStringValidatorErrorDomain]) {
                    NSString * errorDescription = [NSString stringWithFormat:validationError.localizedDescription, textContainer.textField.placeholder];
                    NSDictionary * userInfo = @{ NSLocalizedDescriptionKey : errorDescription };
                    validationError = [NSError errorWithDomain:IQStringValidatorErrorDomain
                                                 code:-1
                                             userInfo:userInfo];
                }
                
                if (error) {
                    *error = validationError;
                }
                
                return NO;
            }
        }
    }
    return YES;
}

@end
