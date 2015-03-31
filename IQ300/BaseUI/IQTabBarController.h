//
//  IQTabBarController.h
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IQTabBarControllerDelegate;

@interface IQTabBarController : UIViewController <UITabBarDelegate>

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, assign) UIViewController * selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, readonly) UITabBar * tabBar;

@property (nonatomic, getter=isSeparatorHidden) BOOL separatorHidden;
@property (nonatomic, assign) CGFloat separatorHeight;
@property (nonatomic, strong) UIColor * separatorColor;

@property(nonatomic, weak) id<IQTabBarControllerDelegate> delegate;

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@end

@protocol IQTabBarControllerDelegate <NSObject>

@optional
- (BOOL)tabBarController:(IQTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(IQTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;

@end