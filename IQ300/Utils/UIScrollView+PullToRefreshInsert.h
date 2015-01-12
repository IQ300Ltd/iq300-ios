//
//  UIScrollView+PullToRefreshInsert.h
//  IQ300
//
//  Created by Tayphoon on 12.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVPullToRefresh/UIScrollView+SVPullToRefresh.h>

@interface UIScrollView (PullToRefreshInsert)

- (void)insertPullToRefreshWithActionHandler:(void (^)(void))actionHandler position:(SVPullToRefreshPosition)position;
- (SVPullToRefreshView*)pullToRefreshForPosition:(SVPullToRefreshPosition)position;

@end
