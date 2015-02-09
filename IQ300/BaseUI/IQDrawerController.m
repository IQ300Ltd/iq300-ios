//
//  IQDrawerController.m
//  IQ300
//
//  Created by Tayphoon on 13.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQDrawerController.h"
#import "IQNavigationController.h"
#import "NSObject+SafelyRemoveObserver.h"

NSString * const IQDrawerDidShowNotification = @"IQDrawerDidShowNotification";
NSString * const IQDrawerDidHideNotification = @"IQDrawerDidHideNotification";
NSString * const IQDrawerNotificationStateKey = @"IQDrawerNotificationStateKey";

NSString * const kOpenSideObservKey = @"openSide";

@interface IQDrawerController() {
    
}

@end

@implementation IQDrawerController

- (id)initWithCenterViewController:(UIViewController *)centerViewController
          leftDrawerViewController:(UIViewController *)leftDrawerViewController
         rightDrawerViewController:(UIViewController *)rightDrawerViewController {
    self = [super initWithCenterViewController:centerViewController
                      leftDrawerViewController:leftDrawerViewController
                     rightDrawerViewController:rightDrawerViewController];
    if(self) {
        [self addObserver:self
               forKeyPath:kOpenSideObservKey
                  options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                  context:nil];
    }
    
    return self;
}


- (void)panGestureCallback:(UIPanGestureRecognizer *)panGesture {
    [super panGestureCallback:panGesture];
    
    UIView * centerContainerView = [super valueForKey:@"_centerContainerView"];
    IQNavigationController * navController = (IQNavigationController*)((UITabBarController*)self.centerViewController).selectedViewController;
    UIView * statusBarView = navController.statusBarView;

    CGRect newFrame = navController.statusBarView.frame;
    newFrame.origin.x = centerContainerView.frame.origin.x;
    
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kOpenSideObservKey]) {
        NSString * notificationName = (self.openSide != MMDrawerSideNone) ? IQDrawerDidShowNotification : IQDrawerDidHideNotification;
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:self
                                                          userInfo:@{ IQDrawerNotificationStateKey : @(self.openSide) }];
    }
}

- (void)dealloc {
    [self safelyRemoveObserver:self forKeyPath:kOpenSideObservKey];
}

@end
