//
//  UIViewController+LeftMenu.m
//  IQ300
//
//  Created by Tayphoon on 20.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import "UIViewController+LeftMenu.h"

@implementation UIViewController (LeftMenu)

- (MenuViewController*)leftMenuController {
    if(self.mm_drawerController) {
        return ((MenuViewController*)self.mm_drawerController.leftDrawerViewController);
    }
    return nil;
}

@end
