//
//  ExtendedButton.h
//  IQ300
//
//  Created by Tayphoon on 07.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExtendedButton : UIButton

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

- (void)setBorderColor:(UIColor *)borderColor forState:(UIControlState)state;

- (void)setFont:(UIFont *)font forState:(UIControlState)state;

@end
