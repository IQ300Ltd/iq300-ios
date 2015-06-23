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
    
    _transitionView = [[UIView alloc] init];
    [_transitionView setClipsToBounds:YES];
    [self.view addSubview:_transitionView];
    
    [self rebuildTabBarItemsAnimated:NO];
    
    //Call transitions
    NSUInteger selectedIndex = self.selectedIndex;
    _selectedIndex = NSNotFound;
    self.selectedIndex = selectedIndex;
    
    BOOL separatorHidden = _separatorHidden;
    _separatorHidden = YES;
    [self setSeparatorHidden:separatorHidden];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //try fix ios 7 tab not selected
    if (_selectedIndex != NSNotFound) {
        [self.tabBar setSelectedItem:self.tabBar.items[_selectedIndex]];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect actualBounds = self.view.bounds;
    
    if (!_separatorHidden) {
        _separatorView.frame = CGRectMake(actualBounds.origin.x,
                                          actualBounds.origin.y,
                                          actualBounds.size.width,
                                          _separatorHeight);
    }
    
    CGFloat tabBarY = (!_separatorHidden) ? CGRectBottom(_separatorView.frame) : actualBounds.origin.y;
    self.tabBar.frame = CGRectMake(actualBounds.origin.x,
                               tabBarY,
                               actualBounds.size.width,
                               TABBAR_HEIGHT);
    
    CGFloat transitionY = CGRectBottom(self.tabBar.frame);
    _transitionView.frame = CGRectMake(actualBounds.origin.x,
                                       transitionY,
                                       actualBounds.size.width,
                                       actualBounds.size.height - transitionY);
    
    UIView * childView = [_transitionView.subviews firstObject];
    childView.frame = _transitionView.bounds;
}

#pragma mark - Public methods

- (void)setSeparatorHidden:(BOOL)separatorHidden {
    if(_separatorHidden != separatorHidden) {
        _separatorHidden = separatorHidden;
        if (!_separatorHidden) {
            _separatorView = [[UIView alloc] init];
            _separatorView.backgroundColor = _separatorColor;
            if (self.isViewLoaded) {
                [self.view addSubview:_separatorView];
                [self.view setNeedsLayout];
            }
        }
        else {
            [_separatorView removeFromSuperview];
            _separatorView = nil;
            if (self.isViewLoaded) {
                [self.view setNeedsLayout];
            }
        }
    }
}

- (void)setSeparatorHeight:(CGFloat)separatorHeight {
    _separatorHeight = separatorHeight;
    if (!self.isSeparatorHidden && self.isViewLoaded) {
        [self.view setNeedsLayout];
    }
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    if (!self.isSeparatorHidden && _separatorView) {
        _separatorView.backgroundColor = _separatorColor;
    }
}

- (UIView<IQTabBar>*)tabBar {
    if (!_tabBar) {
        _tabBar = (UIView<IQTabBar>*)[[UITabBar alloc] init];
        _tabBar.delegate = self;
        [self.view addSubview:_tabBar];
    }
    return _tabBar;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    UIViewController * oldSelectedViewController = self.selectedViewController;
    
    for (UIViewController *viewController in _viewControllers) {
        [viewController willMoveToParentViewController:nil];
        [viewController removeFromParentViewController];
    }
    
    _viewControllers = [viewControllers copy];
    
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

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated {
    if (_selectedIndex != newSelectedIndex) {
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
                [fromViewController willMoveToParentViewController:nil];
                [fromViewController removeFromParentViewController];
                [fromViewController.view removeFromSuperview];
            }
            
            [toViewController willMoveToParentViewController:self];
            [self addChildViewController:toViewController];
            [toViewController didMoveToParentViewController:self];
            
            toViewController.view.frame = _transitionView.bounds;
            [_transitionView addSubview:toViewController.view];
            
            NSInteger tabIndex = [self.tabBar.items indexOfObject:self.tabBar.selectedItem];
            if (tabIndex != _selectedIndex) {
                [self.tabBar setSelectedItem:self.tabBar.items[_selectedIndex]];
            }
            
            if ([self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
                [self.delegate tabBarController:self didSelectViewController:toViewController];
            }
        }
    }
}

#pragma mark - TabBar Delegate

- (void)tabBar:(UIView<IQTabBar> *)tabBar didSelectItem:(UITabBarItem *)item {
    NSUInteger selectedIndex = [self.tabBar.items indexOfObject:item];
    [self setSelectedIndex:selectedIndex];
}

#pragma mark - Private methods

- (void)rebuildTabBarItemsAnimated:(BOOL)animated {
    NSMutableArray * tabBarItems = [NSMutableArray array];
    
    for (NSInteger index = 0; index < [_viewControllers count]; index++) {
        UIViewController * controller = _viewControllers[index];
        if(controller.tabBarItem) {
            [tabBarItems insertObject:controller.tabBarItem atIndex:index];
        }
        else {
            UITabBarItem * tabBarItem = [[UITabBarItem alloc] initWithTitle:controller.title image:[UIImage new] tag:index];
            [tabBarItems insertObject:tabBarItem atIndex:index];
        }
    }
    
    [self.tabBar setItems:tabBarItems animated:animated];
    
    if(_selectedIndex > 0 && _selectedIndex < [tabBarItems count]) {
        [self.tabBar setSelectedItem:tabBarItems[_selectedIndex]];
    }
}

@end
