//
//  TabChildController.m
//  IQ300
//
//  Created by Tayphoon on 19.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "TabChildController.h"

@interface TabChildController ()

@end

@implementation TabChildController

- (MenuViewController*)leftMenuController {
    if(self.mm_drawerController) {
        return ((MenuViewController*)self.mm_drawerController.leftDrawerViewController);
    }
    return nil;
}

@end
