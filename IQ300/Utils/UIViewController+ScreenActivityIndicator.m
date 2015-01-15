//
//  UIViewController+ScreenActivityIndicator.m
//  IQ300
//
//  Created by Tayphoon on 11.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <objc/runtime.h>

#import "UIViewController+ScreenActivityIndicator.h"

NSString const *UIViewController_indicatorViewKey = @"UIViewController_indicatorViewKey";

@implementation UIViewController (ScreenActivityIndicator)

+ (void)initialize {
    
}

+ (UIWindow*)keyWindow {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    return window;
}

+ (UIView*)getViewByClass:(Class)viewClass {
    UIWindow* window = [UIViewController keyWindow];
    
    UIView * resultView = nil;
    if (window) {
        NSArray * subviews = [window subviews];
        for(int i = (int)[subviews count] - 1; i >= 0; i--) {
            UIView * view = [subviews objectAtIndex:i];
            if([view isKindOfClass:viewClass]) {
                resultView = view;
                break;
            }
        }
    }
    return resultView;
}

- (UIView*)indicatorView {
    UIView * loadingDimmingView = objc_getAssociatedObject(self, &UIViewController_indicatorViewKey);
    UIActivityIndicatorView * loadingIndicator = ([[loadingDimmingView subviews] count] > 0 ) ? [[loadingDimmingView subviews] objectAtIndex:0] : nil;
    
    if(!loadingDimmingView || !loadingIndicator) {
        loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingIndicator sizeToFit];
        [loadingIndicator setHidesWhenStopped:YES];
        NSLayoutConstraint *heightConstraint =
        [NSLayoutConstraint constraintWithItem:loadingIndicator
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:loadingIndicator.frame.size.height];
        [loadingIndicator addConstraint:heightConstraint];
        
        NSLayoutConstraint *widthConstraint =
        [NSLayoutConstraint constraintWithItem:loadingIndicator
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:loadingIndicator.frame.size.width];
        [loadingIndicator addConstraint:widthConstraint];
        
        loadingDimmingView = [[UIView alloc] init];
        loadingDimmingView.backgroundColor = [UIColor blackColor];
        loadingDimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        loadingDimmingView.opaque = NO;
        loadingDimmingView.alpha = 0.7f;
        [loadingDimmingView addSubview:loadingIndicator];
        loadingIndicator.center = loadingDimmingView.center;
        objc_setAssociatedObject(self, &UIViewController_indicatorViewKey, loadingDimmingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return loadingDimmingView;
}

- (UIView*)getControllerDimmingView {
    UIView * dimmingView = [self valueForKey:@"_dimmingView"];
    if(!dimmingView){
        dimmingView = [UIViewController getViewByClass:NSClassFromString(@"UIDimmingView")];
    }
    return dimmingView;
}

- (void)setControllerDimmingViewHidden:(BOOL)hidden {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIView * dimmingView = [self getControllerDimmingView];
    
    if(dimmingView) {
        dimmingView.frame = (!hidden) ? screenRect : CGRectZero;
    }
}

- (void)showActivityIndicator {
    UIView * indicatorView = [self indicatorView];
    UIActivityIndicatorView * loadingIndicator = ([[indicatorView subviews] count] > 0 ) ? [[indicatorView subviews] objectAtIndex:0] : nil;
    UIWindow * window = [UIViewController keyWindow];
    [indicatorView setFrame:window.bounds];
    [window addSubview:indicatorView];
    loadingIndicator.center = indicatorView.center;

    if(loadingIndicator) {
        [loadingIndicator startAnimating];
    }
}

- (void)showActivityIndicatorOnView:(UIView*)view {
    UIView * indicatorView = [self indicatorView];
    UIActivityIndicatorView * loadingIndicator = ([[indicatorView subviews] count] > 0 ) ? [[indicatorView subviews] objectAtIndex:0] : nil;
    [indicatorView setFrame:view.bounds];
    [view addSubview:indicatorView];
    loadingIndicator.center = indicatorView.center;

    if(loadingIndicator) {
        [loadingIndicator startAnimating];
    }
}

- (void)hideActivityIndicator {
    UIView * indicatorView = [self indicatorView];
    UIActivityIndicatorView * loadingIndicator = ([[indicatorView subviews] count] > 0 ) ? [[indicatorView subviews] objectAtIndex:0] : nil;
    if(loadingIndicator) {
        [loadingIndicator stopAnimating];
    }
    
    [indicatorView removeFromSuperview];
}

- (void)setActivityIndicatorBackgroundColor:(UIColor*)backgroundColor {
    UIView * indicatorView = [self indicatorView];
    [indicatorView setBackgroundColor:backgroundColor];
}

- (void)setActivityIndicatorStyle:(UIActivityIndicatorViewStyle)viewStyle {
    UIView * indicatorView = [self indicatorView];
    UIActivityIndicatorView * loadingIndicator = ([[indicatorView subviews] count] > 0 ) ? [[indicatorView subviews] objectAtIndex:0] : nil;
    loadingIndicator.activityIndicatorViewStyle = viewStyle;
}

@end
