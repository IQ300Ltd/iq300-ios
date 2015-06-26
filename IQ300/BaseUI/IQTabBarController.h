//
//  IQTabBarController.h
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTabBar.h"

@protocol IQTabBarControllerDelegate;

@interface IQTabBarController : UIViewController <IQTabBarDelegate> {
@protected
    UIView * _transitionView;
    UIView * _separatorView;
}

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, assign) UIViewController * selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) UIView<IQTabBar> * tabBar;

@property (nonatomic, getter=isSeparatorHidden) BOOL separatorHidden;
@property (nonatomic, assign) CGFloat separatorHeight;
@property (nonatomic, strong) UIColor * separatorColor;

@property (nonatomic, readonly) UIViewController * presentedController;

@property(nonatomic, weak) id<IQTabBarControllerDelegate> delegate;

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated;

- (void)presentViewController:(UIViewController *)viewControllerToPresent;

- (void)willTransitionToViewController:(UIViewController *)viewController;
- (void)willTransitionFromViewController:(UIViewController *)viewController;

@end

@protocol IQTabBarControllerDelegate <NSObject>

@optional
- (BOOL)tabBarController:(IQTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(IQTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;

@end