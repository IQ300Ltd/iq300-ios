//
//  LeftSideTabBar.m
//  IQ300
//
//  Created by Tayphoon on 02.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <objc/runtime.h>

#import "LeftSideTabBar.h"

CGFloat const LogoImageHeight = 54.0f;

NSString const * UITabBarItemViewKey = @"UITabBarItemViewKey";

@interface UITabBarItem(TabItemView)

@property (nonatomic, strong) id tabItemView;

@end

@implementation UITabBarItem(TabItemView)

- (void)setTabItemView:(id)tabItemView {
    objc_setAssociatedObject(self, &UITabBarItemViewKey, tabItemView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)tabItemView {
    return objc_getAssociatedObject(self, &UITabBarItemViewKey);
}

@end

@interface LeftSideTabBar() {
    UIImageView * _backgroundImageView;
    UIImageView * _logoImageView;
}

@end

@implementation LeftSideTabBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.image = [[UITabBar appearance].backgroundImage resizableImageWithCapInsets:UIEdgeInsetsZero];
        _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_backgroundImageView];
        
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.image = [UIImage imageNamed:@"white_logo"];
        _logoImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_logoImageView];

        _feedbackButton = [[UIButton alloc] init];
        _feedbackButton.clipsToBounds = YES;
        _feedbackButton.adjustsImageWhenHighlighted = NO;
        [_feedbackButton setImage:[UIImage imageNamed:@"feedback_ico.png"]
                         forState:UIControlStateNormal];
        
        [_feedbackButton setImage:[UIImage imageNamed:@"feedback_ico_selected.png"]
                         forState:UIControlStateHighlighted];
        
        [self addSubview:_feedbackButton];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appearanceDidChangeNotification)
                                                     name:@"_UIAppearanceInvocationsDidChangeNotification"
                                                   object:nil];
    }
    return self;
}

- (void)setSelectedItem:(UITabBarItem *)selectedItem {
    if (_selectedItem != selectedItem) {
        if (_selectedItem) {
            UIButton * tabItemButton = _selectedItem.tabItemView;
            
            [tabItemButton setImage:_selectedItem.image
                           forState:UIControlStateNormal];

            [tabItemButton setBackgroundImage:nil
                                     forState:UIControlStateNormal];
        }
        
        _selectedItem = selectedItem;
        
        if (_selectedItem) {
            UIButton * tabItemButton = _selectedItem.tabItemView;
            UIImage * selectedImage = _selectedItem.selectedImage;
            
            [tabItemButton setImage:selectedImage
                           forState:UIControlStateNormal];
            [tabItemButton setBackgroundImage:[self internalSelectionIndicatorImage]
                                     forState:UIControlStateNormal];
        }
    }
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated {
    for (UITabBarItem * tabItem in _items) {
        id tabItemView = tabItem.tabItemView;
        [tabItemView removeFromSuperview];
    }
    
    _items = [items copy];

    if ([_items count] > 0) {
        for (NSUInteger index = 0; index < [_items count]; index++) {
            UITabBarItem * tabItem = _items[index];
            id tabItemView = tabItem.tabItemView;
            if(tabItemView == nil) {
                UIButton * tabItemButton = [[UIButton alloc] init];
                tabItemButton.adjustsImageWhenHighlighted = NO;
                tabItemButton.tag = index;

                [tabItemButton setImage:tabItem.image
                               forState:UIControlStateNormal];
                
                [tabItemButton addTarget:self
                                  action:@selector(tabItemButtonAction:)
                        forControlEvents:UIControlEventTouchUpInside];
                tabItemView = tabItemButton;
                [tabItem setTabItemView:tabItemView];
                if ([tabItem respondsToSelector:@selector(setView:)]) {
                    [tabItem setValue:tabItemView forKey:@"view"];
                }
            }
            
            [self addSubview:tabItemView];
        }
    }
    
    [self bringSubviewToFront:_feedbackButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect actualBounds = self.bounds;

    _backgroundImageView.frame = actualBounds;
    
    _logoImageView.frame = CGRectMake(actualBounds.origin.x,
                                      actualBounds.origin.y + 10.0f,
                                      actualBounds.size.width,
                                      LogoImageHeight);
    
    CGFloat tabItemViewY = CGRectBottom(_logoImageView.frame);
    CGFloat itemsViewHeight = 64.0f;
    
    for (UITabBarItem * item in _items) {
        UIView * tabItemView = item.tabItemView;
        tabItemView.frame = CGRectMake(actualBounds.origin.x,
                                tabItemViewY,
                                actualBounds.size.width - 1.0f,
                               itemsViewHeight);
        tabItemViewY += tabItemView.frame.size.height;
    }
    
    _feedbackButton.frame = CGRectMake(actualBounds.origin.x,
                                       actualBounds.origin.y + actualBounds.size.height - itemsViewHeight,
                                       actualBounds.size.width - 1.0f,
                                       itemsViewHeight);
}

#pragma mark - UIAppearance notification

- (void)appearanceDidChangeNotification {
    _backgroundImageView.image = [self internalBackgroundImage];
    
    if (_selectedItem) {
        UIButton * tabItemButton = _selectedItem.tabItemView;
        [tabItemButton setBackgroundImage:[self internalSelectionIndicatorImage]
                                 forState:UIControlStateNormal];
    }
}

#pragma mark - Private methods

- (void)tabItemButtonAction:(UIButton*)sender {
    NSInteger index = sender.tag;
    
    if (index >= 0 && index < [_items count]) {
        UITabBarItem * item = _items[index];

        [self setSelectedItem:item];
        if ([self.delegate respondsToSelector:@selector(tabBar:didSelectItem:)]) {
            [self.delegate tabBar:self didSelectItem:item];
        }
    }
}

- (UIImage*)internalSelectionIndicatorImage {
    if (!_selectionIndicatorImage) {
        return [UITabBar appearance].selectionIndicatorImage;
    }
    return _selectionIndicatorImage;
}

- (UIImage*)internalBackgroundImage {
    if (!_backgroundImage) {
        return [UITabBar appearance].backgroundImage;
    }
    return _backgroundImage;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
