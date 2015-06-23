//
//  UIViewController+LeftMenu.h
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "MenuViewController.h"
#ifdef IPAD
#import "LeftSideTabBarController.h"
#endif

@interface UIViewController (LeftMenu)

@property (nonatomic, readonly) MenuViewController * leftMenuController;
#ifdef IPAD
@property (nonatomic, readonly) LeftSideTabBarController * leftTabBarController;
#endif

@end
