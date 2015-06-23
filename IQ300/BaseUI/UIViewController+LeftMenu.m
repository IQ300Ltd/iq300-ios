//
//  UIViewController+LeftMenu.m
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import "UIViewController+LeftMenu.h"

#ifdef IPAD
#import "LeftSideTabBarController.h"
#endif

@implementation UIViewController (LeftMenu)

- (MenuViewController*)leftMenuController {
#ifdef IPAD
        LeftSideTabBarController * leftTabBarController = self.leftTabBarController;
        return (MenuViewController*)leftTabBarController.menuController;
#else
    if(self.mm_drawerController) {
        return ((MenuViewController*)self.mm_drawerController.leftDrawerViewController);
    }
    return nil;
#endif
}

#ifdef IPAD
- (LeftSideTabBarController*)leftTabBarController {
    UIViewController *parentViewController = self.parentViewController;
    while (parentViewController != nil) {
        if([parentViewController isKindOfClass:[LeftSideTabBarController class]]){
            return (LeftSideTabBarController *)parentViewController;
        }
        parentViewController = parentViewController.parentViewController;
    }
    return nil;
}
#endif

@end
