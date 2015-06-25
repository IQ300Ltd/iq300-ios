//
//  LeftSideTabBarController.m
//  IQ300
//
//  Created by Tayphoon on 01.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "LeftSideTabBarController.h"
#import "LeftSideTabBar.h"
#import "FeedbacksController.h"

CGFloat const TabBarWidth = 64.0f;
NSTimeInterval const LSAnimationDuration = 0.15f;

@interface LeftSideTabBarController () {
    
}

@end

@implementation LeftSideTabBarController

- (void)viewDidLoad {
    LeftSideTabBar * tabBar = [[LeftSideTabBar alloc] init];
    [tabBar.feedbackButton addTarget:self
                              action:@selector(feedbacButtonAction:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    self.tabBar = tabBar;
    self.tabBar.delegate = self;
    [self.view addSubview:self.tabBar];
    
    [super viewDidLoad];
}

- (void)setMenuController:(UIViewController *)menuController {
    if(_menuController) {
        [_menuController willMoveToParentViewController:nil];
        [_menuController removeFromParentViewController];
        [_menuController.view removeFromSuperview];
    }
    
    _menuController = menuController;
    
    if (_menuController) {
        _menuController.view.clipsToBounds = YES;
        [_menuController willMoveToParentViewController:self];
        [self addChildViewController:_menuController];
        [_menuController didMoveToParentViewController:self];
        [self.view addSubview:_menuController.view];
        [self.view sendSubviewToBack:_menuController.view];
        if (self.isViewLoaded) {
            [self layoutSubviews];
        }
    }
}

- (void)setMenuControllerWidth:(CGFloat)menuControllerWidth {
    if (_menuControllerWidth != menuControllerWidth) {
        _menuControllerWidth = menuControllerWidth;
        if (self.isViewLoaded) {
            [self layoutSubviews];
        }
    }
}

- (void)setMenuControllerHidden:(BOOL)menuControllerHidden {
    [self setMenuControllerHidden:menuControllerHidden animated:YES];
}

- (void)setMenuControllerHidden:(BOOL)menuControllerHidden animated:(BOOL)animated {
    if (_menuControllerHidden != menuControllerHidden) {
        _menuControllerHidden = menuControllerHidden;
        
        if (self.isViewLoaded && _menuController) {
            if (animated) {
                CGRect actualBounds = self.view.bounds;
                BOOL isMenuControllerHidden = (self.isMenuControllerHidden || !self.menuController);
                CGFloat menuControllerX = (!isMenuControllerHidden) ? CGRectRight(self.tabBar.frame) :
                CGRectRight(self.tabBar.frame) - self.menuControllerWidth;
                CGRect menuControllerRect = CGRectMake(menuControllerX,
                                                       self.view.frame.origin.y,
                                                       self.menuControllerWidth,
                                                       self.view.frame.size.height);
                CGFloat transitionX = CGRectRight(menuControllerRect);
                CGRect transitionViewRect = CGRectMake(transitionX,
                                                       actualBounds.origin.y,
                                                       actualBounds.size.width - transitionX,
                                                       actualBounds.size.height);
                UIView * childView = [_transitionView.subviews firstObject];

                [UIView animateWithDuration:(_menuControllerHidden) ? 0.35f : 0.35f
                                      delay:0.0f
                                    options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationCurveEaseOut
                                 animations:^{
                                     self.menuController.view.frame = menuControllerRect;
                                     _transitionView.frame = transitionViewRect;
                                     childView.frame = _transitionView.bounds;
                                 }
                                 completion:^(BOOL finished) {
                                 }];
            }
            else {
                [self layoutSubviews];
            }
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated {
    if (self.selectedIndex != newSelectedIndex) {
        if (newSelectedIndex != NSNotFound) {
            UIViewController * toViewController = self.viewControllers[newSelectedIndex];
            if ([toViewController isKindOfClass:[UINavigationController class]]) {
                toViewController = ((UINavigationController*)toViewController).topViewController;
            }
            
            BOOL isLeftMenuShouldHidden = [self isMenuShouldHiddenForController:toViewController];
            [self setMenuControllerHidden:isLeftMenuShouldHidden animated:NO];
        }
        [super setSelectedIndex:newSelectedIndex animated:animated];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [self layoutSubviews];
}

#pragma mark - Private methods

- (void)layoutSubviews {
    CGRect actualBounds = self.view.bounds;
    
    if (!self.separatorHidden) {
        _separatorView.frame = CGRectMake(actualBounds.origin.x,
                                          actualBounds.origin.y,
                                          actualBounds.size.width,
                                          self.separatorHeight);
    }
    
    CGFloat tabBarY = (!self.separatorHidden) ? CGRectBottom(_separatorView.frame) : actualBounds.origin.y;
    self.tabBar.frame = CGRectMake(actualBounds.origin.x,
                                   tabBarY,
                                   TabBarWidth,
                                   actualBounds.size.height);
    
    BOOL isMenuControllerHidden = (self.isMenuControllerHidden || !self.menuController);
    CGFloat menuControllerX = (!isMenuControllerHidden) ? CGRectRight(self.tabBar.frame) : CGRectRight(self.tabBar.frame) - self.menuControllerWidth;
    self.menuController.view.frame = CGRectMake(menuControllerX,
                                                self.view.frame.origin.y,
                                                self.menuControllerWidth,
                                                self.view.frame.size.height);
    
    
    CGFloat transitionX = CGRectRight(self.menuController.view.frame);
    _transitionView.frame = CGRectMake(transitionX,
                                       actualBounds.origin.y,
                                       actualBounds.size.width - transitionX,
                                       actualBounds.size.height);
    
    UIView * childView = [_transitionView.subviews firstObject];
    childView.frame = _transitionView.bounds;
}

- (BOOL)isMenuShouldHiddenForController:(UIViewController*)viewController {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selector = @selector(isLeftMenuEnabled);
    BOOL isLeftMenuEnabled = ([viewController respondsToSelector:selector]) ? [[viewController performSelector:selector] boolValue] :
                                                                              YES;
#pragma clang diagnostic pop

    return !isLeftMenuEnabled;
}

- (void)changeLayer:(CALayer*)layer frame:(CGRect)frame {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"frame"];
    animation.fromValue = [NSValue valueWithCGRect:layer.bounds];
    animation.toValue = [NSValue valueWithCGRect:frame];
    animation.duration = 0.35f;
    layer.frame = frame;
    [layer addAnimation:animation forKey:@"frame"];
}

- (void)feedbacButtonAction:(id)sender {
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        FeedbacksController * controller = [[FeedbacksController alloc] init];
        
        UINavigationController * navController = (UINavigationController*)self.selectedViewController;
        [navController pushViewController:controller animated:YES];
    }
}

@end
