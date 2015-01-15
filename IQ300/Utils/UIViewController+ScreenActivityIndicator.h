//
//  UIViewController+ScreenActivityIndicator.h
//  IQ300
//
//  Created by Tayphoon on 11.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ScreenActivityIndicator)

- (void)showActivityIndicator;
- (void)showActivityIndicatorOnView:(UIView*)view;
- (void)hideActivityIndicator;

- (void)setActivityIndicatorBackgroundColor:(UIColor*)backgroundColor;
- (void)setActivityIndicatorStyle:(UIActivityIndicatorViewStyle)viewStyle;

@end
