//
//  UIViewController+LeftMenu.m
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import "UIViewController+LeftMenu.h"
#import "LeftSideTabBarController.h"

@implementation UIViewController (LeftMenu)

- (MenuViewController*)leftMenuController {
    if(!IS_IPAD && self.mm_drawerController) {
        return ((MenuViewController*)self.mm_drawerController.leftDrawerViewController);
    }
    else if(IS_IPAD) {
        LeftSideTabBarController * leftTabBarController = self.leftTabBarController;
        return (MenuViewController*)leftTabBarController.menuController;
    }
    return nil;
}

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

@end
