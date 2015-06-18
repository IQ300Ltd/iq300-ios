//
//  RegistrationView.h
//  IQ300
//
//  Created by Tayphoon on 17.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTextContainer.h"
#import "ExtendedButton.h"
#import "IQTextView.h"

@interface RegistrationView : UIView

@property (nonatomic, readonly) UIImageView * logoImageView;
@property (nonatomic, readonly) IQTextContainer * nameContainer;
@property (nonatomic, readonly) IQTextContainer * surnameContainer;
@property (nonatomic, readonly) IQTextContainer * organizationContainer;
@property (nonatomic, readonly) IQTextContainer * emailContainer;
@property (nonatomic, readonly) IQTextContainer * passwordContainer;
@property (nonatomic, readonly) UILabel * errorLabel;
@property (nonatomic, readonly) ExtendedButton * signupButton;
@property (nonatomic, readonly) UIButton * enterButton;
@property (nonatomic, readonly) IQTextView * helpTextView;

- (void)setScrollViewOffset:(CGFloat)offset;
- (void)scrollToFieldWithTag:(NSInteger)tag animated:(BOOL)animated;
- (IQTextContainer*)fieldViewWithTag:(NSInteger)tag;
- (void)setTextFieldDelegate:(id<UITextFieldDelegate>)delegate;
- (BOOL)validateFieldsWithError:(NSError**)error;

@end
