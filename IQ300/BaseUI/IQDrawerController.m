//
//  IQDrawerController.m
//  IQ300
//
//  Created by Tayphoon on 13.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQDrawerController.h"
#import "IQNavigationController.h"

@interface IQDrawerController() {
}

@end

@implementation IQDrawerController

- (void)panGestureCallback:(UIPanGestureRecognizer *)panGesture {
    [super panGestureCallback:panGesture];
    
    UIView * centerContainerView = [super valueForKey:@"_centerContainerView"];
    IQNavigationController * navController = (IQNavigationController*)((UITabBarController*)self.centerViewController).selectedViewController;
    UIView * statusBarView = navController.statusBarView;

    CGRect newFrame = navController.statusBarView.frame;
    newFrame.origin.x = centerContainerView.frame.origin.x + 3;
    
    statusBarView.frame = newFrame;
}

- (void)prepareToPresentDrawer:(MMDrawerSide)drawer animated:(BOOL)animated {
    [super prepareToPresentDrawer:drawer animated:animated];
}

- (void)closeDrawerAnimated:(BOOL)animated velocity:(CGFloat)velocity animationOptions:(UIViewAnimationOptions)options completion:(void (^)(BOOL))completion {
    if (![[super valueForKey:@"isAnimatingDrawer"] boolValue]) {
        IQNavigationController * navController = (IQNavigationController*)((UITabBarController*)self.centerViewController).selectedViewController;
        UIView * statusBarView = navController.statusBarView;
        
        CGRect newFrame = statusBarView.frame;
        newFrame.origin.x = 0;
        
        UIView * centerContainerView = [super valueForKey:@"_centerContainerView"];
        CGFloat distance = ABS(CGRectGetMinX(centerContainerView.frame));
        NSTimeInterval duration = MAX(distance/ABS(velocity),0.15f);
        
        [UIView animateWithDuration:(animated?duration:0.0)
                              delay:0.0
                            options:options
                         animations:^{
                             statusBarView.frame = newFrame;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    [super closeDrawerAnimated:animated velocity:velocity animationOptions:options completion:completion];
}

- (void)openDrawerSide:(MMDrawerSide)drawerSide animated:(BOOL)animated velocity:(CGFloat)velocity animationOptions:(UIViewAnimationOptions)options completion:(void (^)(BOOL))completion {
    if (![[super valueForKey:@"isAnimatingDrawer"] boolValue]) {
        IQNavigationController * navController = (IQNavigationController*)((UITabBarController*)self.centerViewController).selectedViewController;
        UIView * statusBarView = navController.statusBarView;
        
        UIView * centerContainerView = [super valueForKey:@"_centerContainerView"];
        CGRect oldFrame = centerContainerView.frame;
       
        CGRect newFrame = statusBarView.frame;
     
        if(drawerSide == MMDrawerSideLeft){
            newFrame.origin.x = self.maximumLeftDrawerWidth + 3;
        }
        else {
            newFrame.origin.x = 0-self.maximumRightDrawerWidth + 3;
        }
        
        CGFloat distance = ABS(CGRectGetMinX(oldFrame)-self.maximumLeftDrawerWidth);
        NSTimeInterval duration = MAX(distance/ABS(velocity), 0.15f);
        
        [UIView animateWithDuration:(animated?duration:0.0)
                              delay:0.0
                            options:options
                         animations:^{
                             statusBarView.frame = newFrame;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    [super openDrawerSide:drawerSide animated:animated velocity:velocity animationOptions:options completion:completion];
}

@end
