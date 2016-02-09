//
//  IQNavigationController.m
//  IQ300
//
//  Created by Tayphoon on 11.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <MMDrawerController/MMDrawerBarButtonItem.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "IQNavigationController.h"
#import "UIViewController+LeftMenu.h"

@interface IQNavigationController() <UINavigationControllerDelegate> {
    UIView * _statusBarView;
}

@end

@implementation IQNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if(self) {
        self.delegate = self;
    }
    return self;
}

- (UIView*)statusBarView {
    if(!_statusBarView) {
        _statusBarView = [[UIApplication sharedApplication] valueForKey:[@[@"status", @"Bar"] componentsJoinedByString:@""]];
    }
    return _statusBarView;
}

- (void)leftDrawerButtonPress:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    BOOL isLeftMenuEnabled = [self isLeftMenuEnabledForController:viewController];
//    
//#ifdef IPAD
//    LeftSideTabBarController * rootTabController = self.leftTabBarController;
//    [rootTabController setMenuControllerHidden:!isLeftMenuEnabled animated:animated];
//#endif
//
//    if (animated) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [super pushViewController:viewController animated:animated];
//        });
//    }
//    else {
//        [super pushViewController:viewController animated:animated];
//    }
//}
//
//- (UIViewController*)popViewControllerAnimated:(BOOL)animated {
//    UIViewController * viewController = ([self.viewControllers count] > 1) ? self.viewControllers[[self.viewControllers count] - 2] : nil;
//    BOOL isLeftMenuEnabled = [self isLeftMenuEnabledForController:viewController];
//    
//    LeftSideTabBarController * rootTabController = self.leftTabBarController;
//    [rootTabController setMenuControllerHidden:!isLeftMenuEnabled animated:animated];
//    
//    if (animated) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [super popViewControllerAnimated:animated];
//        });
//    }
//    else {
//        return [super popViewControllerAnimated:animated];
//    }
//    
//    return nil;
//}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    BOOL isLeftMenuEnabled = [self isLeftMenuEnabledForController:viewController];

#ifdef IPAD
    LeftSideTabBarController * rootTabController = self.leftTabBarController;
    [rootTabController setMenuControllerHidden:!isLeftMenuEnabled animated:animated];
#else
    if(isLeftMenuEnabled) {
        MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self
                                                                                          action:@selector(leftDrawerButtonPress:)];
        [viewController.navigationItem setLeftBarButtonItem:leftDrawerButton
                                                   animated:YES];
    }
    
    [self.mm_drawerController setOpenDrawerGestureModeMask:(isLeftMenuEnabled) ? MMOpenDrawerGestureModeCustom :
                                                                                 MMOpenDrawerGestureModeNone];
#endif
}

- (BOOL)isLeftMenuEnabledForController:(UIViewController *)viewController {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selector = @selector(isLeftMenuEnabled);
    if ([viewController respondsToSelector:selector]) {
        return [[viewController performSelector:selector] boolValue];
    }
#pragma clang diagnostic pop
    return  YES;
}

@end
