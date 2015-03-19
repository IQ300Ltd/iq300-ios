//
//  IQTabBarController.m
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTabBarController.h"

#define TABBAR_HEIGHT 44

@interface IQTabBarController () {
    UITabBar * _tabBar;
    UIView * _transitionView;
    NSMutableArray * _tabBarItems;
}

@end

@implementation IQTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        _selectedIndex = NSNotFound;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tabBar = [[UITabBar alloc] init];
    _tabBar.delegate = self;
    [self.view addSubview:_tabBar];
    
    _transitionView = [[UIView alloc] init];
    [_transitionView setClipsToBounds:YES];
    [self.view addSubview:_transitionView];
    
    [self rebuildTabBarItemsAnimated:NO];
    
    //Call transitions
    NSUInteger selectedIndex = self.selectedIndex;
    _selectedIndex = NSNotFound;
    self.selectedIndex = selectedIndex;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect actualBounds = self.view.bounds;
    
    _tabBar.frame = CGRectMake(actualBounds.origin.x,
                               actualBounds.origin.y,
                               actualBounds.size.width,
                               TABBAR_HEIGHT);
    
    CGFloat transitionY = CGRectBottom(_tabBar.frame);
    _transitionView.frame = CGRectMake(actualBounds.origin.x,
                                       transitionY,
                                       actualBounds.size.width,
                                       actualBounds.size.height - transitionY);
    
    UIView * childView = ([_transitionView.subviews count] > 0) ? [[_transitionView subviews] objectAtIndex:0] : nil;
    childView.frame = _transitionView.bounds;
}

#pragma mark - Public methods

- (UITabBar*)tabBar {
    return _tabBar;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    
    UIViewController *oldSelectedViewController = self.selectedViewController;
    
    for (UIViewController *viewController in _viewControllers) {
        [viewController willMoveToParentViewController:nil];
        [viewController removeFromParentViewController];
    }
    
    _viewControllers = [viewControllers copy];
    
    for (UIViewController *viewController in _viewControllers) {
        [viewController willMoveToParentViewController:self];
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }
    
    NSUInteger newIndex = [_viewControllers indexOfObject:oldSelectedViewController];
    NSUInteger selectedIndex = (newIndex != NSNotFound) ? newIndex : 0;
    if([self isViewLoaded]) {
        [self rebuildTabBarItemsAnimated:animated];
        [self setSelectedIndex:selectedIndex];
    }
    else {
        _selectedIndex = selectedIndex;
    }
}

- (UIViewController *)selectedViewController {
    if (self.selectedIndex != NSNotFound) {
        return self.viewControllers[self.selectedIndex];
    }
    return nil;
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController {
    [self setSelectedViewController:newSelectedViewController animated:YES];
}

- (void)setSelectedViewController:(UIViewController *)newSelectedViewController animated:(BOOL)animated {
    NSUInteger index = [self.viewControllers indexOfObject:newSelectedViewController];
    if (index != NSNotFound) {
        [self setSelectedIndex:index animated:animated];
    }
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex {
    [self setSelectedIndex:newSelectedIndex animated:YES];
}

#pragma mark - TabBar Delegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSUInteger selectedIndex = [_tabBarItems indexOfObject:item];
    [self setSelectedIndex:selectedIndex];
}

#pragma mark - Private methods

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated {
    NSAssert(newSelectedIndex < [self.viewControllers count], @"View controller index out of bounds");
    
    if ([self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        UIViewController * toViewController = self.viewControllers[newSelectedIndex];
        if (![self.delegate tabBarController:self shouldSelectViewController:toViewController]) {
            return;
        }
    }
    
    if(![self isViewLoaded]) {
        _selectedIndex = newSelectedIndex;
    }
    else if(_selectedIndex != newSelectedIndex) {
        UIViewController * fromViewController = (_selectedIndex != NSNotFound) ? self.viewControllers[_selectedIndex] : nil;
        UIViewController * toViewController = self.viewControllers[newSelectedIndex];

        _selectedIndex = newSelectedIndex;

        if(fromViewController) {
            [fromViewController.view removeFromSuperview];
        }
        
        toViewController.view.frame = _transitionView.bounds;
        [_transitionView addSubview:toViewController.view];
        
        NSInteger tabIndex = [_tabBarItems indexOfObject:_tabBar.selectedItem];
        if (tabIndex != _selectedIndex) {
            [_tabBar setSelectedItem:_tabBarItems[_selectedIndex]];
        }
        
        if ([self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
            [self.delegate tabBarController:self didSelectViewController:toViewController];
        }
    }
}

- (void)rebuildTabBarItemsAnimated:(BOOL)animated {
    _tabBarItems = [NSMutableArray array];
    
    for (NSInteger index = 0; index < [_viewControllers count]; index++) {
        UIViewController * controller = _viewControllers[index];
        if(controller.tabBarItem) {
            [_tabBarItems insertObject:controller.tabBarItem atIndex:index];
        }
        else {
            UITabBarItem * tabBarItem = [[UITabBarItem alloc] initWithTitle:controller.title image:[UIImage new] tag:index];
            [_tabBarItems insertObject:tabBarItem atIndex:index];
        }
    }
    
    [_tabBar setItems:_tabBarItems animated:animated];
    
    if(_selectedIndex > 0 && _selectedIndex < [_tabBarItems count]) {
        [_tabBar setSelectedItem:_tabBarItems[_selectedIndex]];
    }
}

@end
