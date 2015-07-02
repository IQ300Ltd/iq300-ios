//
//  UIScrollView+PullToRefreshInsert.m
//  IQ300
//
//  Created by Tayphoon on 12.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <objc/runtime.h>

#import "UIScrollView+PullToRefreshInsert.h"

static CGFloat const SVPullToRefreshViewHeight = 60;

NSString const *UIScrollViewTopPullToRefreshView = @"UIScrollViewTopPullToRefreshView";
NSString const *UIScrollViewBottomPullToRefreshView = @"UIScrollViewBottomPullToRefreshView";

@interface SVPullToRefreshView ()

@property (nonatomic, copy) void (^pullToRefreshActionHandler)(void);

@property (nonatomic, readwrite) SVPullToRefreshState state;
@property (nonatomic, readwrite) SVPullToRefreshPosition position;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, readwrite) CGFloat originalTopInset;
@property (nonatomic, readwrite) CGFloat originalBottomInset;

@property(nonatomic, assign) BOOL isObserving;

- (void)resetScrollViewContentInset;

@end

@implementation UIScrollView (PullToRefreshInsert)

- (void)insertPullToRefreshWithActionHandler:(void (^)(void))actionHandler position:(SVPullToRefreshPosition)position {
    SVPullToRefreshView * pullToRefreshView = [self pullToRefreshForPosition:position];
    
    if(!pullToRefreshView) {
        CGFloat yOrigin;
        switch (position) {
            case SVPullToRefreshPositionTop:
                yOrigin = -SVPullToRefreshViewHeight;
                break;
            case SVPullToRefreshPositionBottom:
                yOrigin = self.contentSize.height;
                break;
            default:
                return;
        }
        pullToRefreshView = [[SVPullToRefreshView alloc] initWithFrame:CGRectMake(0, yOrigin, self.bounds.size.width, SVPullToRefreshViewHeight)];
        pullToRefreshView.pullToRefreshActionHandler = actionHandler;
        pullToRefreshView.scrollView = self;
        [self addSubview:pullToRefreshView];
        
        pullToRefreshView.originalTopInset = self.contentInset.top;
        pullToRefreshView.originalBottomInset = self.contentInset.bottom;
        pullToRefreshView.position = position;

        const void * key = (position == SVPullToRefreshPositionTop) ? &UIScrollViewTopPullToRefreshView : &UIScrollViewBottomPullToRefreshView;
        objc_setAssociatedObject(self, key, pullToRefreshView, OBJC_ASSOCIATION_ASSIGN);
        
        [self setPullToRefreshView:pullToRefreshView shown:YES];
    }
}

- (SVPullToRefreshView*)pullToRefreshForPosition:(SVPullToRefreshPosition)position {
    if (self.pullToRefreshView && self.pullToRefreshView.position == position) {
        return self.pullToRefreshView;
    }
    else {
        const void * key = (position == SVPullToRefreshPositionTop) ? &UIScrollViewTopPullToRefreshView : &UIScrollViewBottomPullToRefreshView;
        return objc_getAssociatedObject(self, key);
    }
}

- (void)setPullToRefreshAtPosition:(SVPullToRefreshPosition)position shown:(BOOL)shown {
    SVPullToRefreshView * pullToRefreshView = [self pullToRefreshForPosition:position];
    pullToRefreshView.hidden = !shown;
    
    if(!shown) {
        if (pullToRefreshView.isObserving) {
            [self removeObserver:pullToRefreshView forKeyPath:@"contentOffset"];
            [self removeObserver:pullToRefreshView forKeyPath:@"contentSize"];
            [self removeObserver:pullToRefreshView forKeyPath:@"frame"];
            [pullToRefreshView resetScrollViewContentInset];
            pullToRefreshView.isObserving = NO;
        }
    }
    else {
        if (!pullToRefreshView.isObserving) {
            [self addObserver:pullToRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:pullToRefreshView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:pullToRefreshView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
            pullToRefreshView.isObserving = YES;
            
            CGFloat yOrigin = 0;
            switch (pullToRefreshView.position) {
                case SVPullToRefreshPositionTop:
                    yOrigin = -SVPullToRefreshViewHeight;
                    break;
                case SVPullToRefreshPositionBottom:
                    yOrigin = self.contentSize.height;
                    break;
            }
            
            pullToRefreshView.frame = CGRectMake(0, yOrigin, self.bounds.size.width, SVPullToRefreshViewHeight);
        }
    }
}

- (void)setPullToRefreshView:(SVPullToRefreshView*)view shown:(BOOL)shown {
    if(!shown) {
        if (view.isObserving) {
            [self removeObserver:view forKeyPath:@"contentOffset"];
            [self removeObserver:view forKeyPath:@"contentSize"];
            [self removeObserver:view forKeyPath:@"frame"];
            [view resetScrollViewContentInset];
            view.isObserving = NO;
        }
    }
    else {
        if (!view.isObserving) {
            [self addObserver:view forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:view forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:view forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
            view.isObserving = YES;
            
            CGFloat yOrigin = 0;
            switch (view.position) {
                case SVPullToRefreshPositionTop:
                    yOrigin = -SVPullToRefreshViewHeight;
                    break;
                case SVPullToRefreshPositionBottom:
                    yOrigin = self.contentSize.height;
                    break;
            }
            
            view.frame = CGRectMake(0, yOrigin, self.bounds.size.width, SVPullToRefreshViewHeight);
        }
    }
}

@end
