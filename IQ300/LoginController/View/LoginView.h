//
//  LoginView.h
//  IQ300
//
//  Created by Tayphoon on 17.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExTextField.h"

@interface LoginView : UIView

@property (nonatomic, readonly) UIImageView * logoImageView;
@property (nonatomic, readonly) ExTextField * emailTextField;
@property (nonatomic, readonly) ExTextField * passwordTextField;
@property (nonatomic, readonly) UIButton * enterButton;
@property (nonatomic, readonly) UIButton * restorePassButton;
@property (nonatomic, readonly) UIButton * registryButton;

@end
