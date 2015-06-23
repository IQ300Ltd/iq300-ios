//
//  LeftSideTabBarController.h
//  IQ300
//
//  Created by Tayphoon on 01.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTabBarController.h"

@interface LeftSideTabBarController : IQTabBarController

@property (nonatomic, strong) UIViewController * menuController;
@property (nonatomic, assign) CGFloat menuControllerWidth;
@property (nonatomic, getter = isMenuControllerHidden) BOOL menuControllerHidden;

- (void)setMenuControllerHidden:(BOOL)menuControllerHidden animated:(BOOL)animated;

@end
