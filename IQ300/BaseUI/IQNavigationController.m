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

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [viewController.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

@end
