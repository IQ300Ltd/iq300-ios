//
//  IQTabBar.h
//  IQ300
//
//  Created by Tayphoon on 01.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

@protocol IQTabBar;


@protocol IQTabBarDelegate <NSObject>

- (void)tabBar:(UIView<IQTabBar> *)tabBar didSelectItem:(UITabBarItem *)item;

@end

@protocol IQTabBar <NSObject>

@property(nonatomic, weak) id<IQTabBarDelegate> delegate;
@property(nonatomic, copy)   NSArray * items;
@property(nonatomic, assign) UITabBarItem * selectedItem;
@property(nonatomic, strong) UIImage *selectionIndicatorImage;
@property(nonatomic, strong) UIImage * backgroundImage;

- (void)setItems:(NSArray *)items animated:(BOOL)animated;

@end