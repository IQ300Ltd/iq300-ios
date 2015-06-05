//
//  LeftSideTabBar.h
//  IQ300
//
//  Created by Tayphoon on 02.06.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQTabBar.h"

@interface LeftSideTabBar : UIView<IQTabBar>

@property(nonatomic, weak)   id<IQTabBarDelegate> delegate;
@property(nonatomic, copy)   NSArray * items;
@property(nonatomic, assign) UITabBarItem * selectedItem;
@property(nonatomic, strong) UIImage * selectionIndicatorImage;
@property(nonatomic, strong) UIImage * backgroundImage;

- (void)setItems:(NSArray *)items animated:(BOOL)animated;

@end
