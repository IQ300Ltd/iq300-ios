//
//  RegistrationStatusView.h
//  IQ300
//
//  Created by Tayphoon on 17.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "ExtendedButton.h"
#import "IQTextView.h"

@interface RegistrationStatusView : UIView

@property (nonatomic, readonly) UIImageView * logoImageView;
@property (nonatomic, readonly) IQTextView * statusTextView;
@property (nonatomic, readonly) ExtendedButton * backButton;

@end
