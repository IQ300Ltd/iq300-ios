//
//  UIBarButtonItem+CustomBadgeView.h
//  IQ300
//
//  Created by Tayphoon on 18.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarItem(CustomBadgeView)

@property (nonatomic, strong) UIView * customBadgeView;
@property (nonatomic, assign) CGPoint badgeOrigin;

@end
