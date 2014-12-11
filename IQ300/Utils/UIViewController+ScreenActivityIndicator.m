//
//  UIViewController+ScreenActivityIndicator.m
//  IQ300
//
//  Created by Tayphoon on 11.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "UIViewController+ScreenActivityIndicator.h"

static UIView * _loadingDimmingView = nil;
static UIActivityIndicatorView * _loadingIndicator = nil;

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

+ (UIView*)indicatorView {
    if(!_loadingDimmingView || !_loadingIndicator) {
        _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_loadingIndicator sizeToFit];
        [_loadingIndicator setHidesWhenStopped:YES];
        NSLayoutConstraint *heightConstraint =
        [NSLayoutConstraint constraintWithItem:_loadingIndicator
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:_loadingIndicator.frame.size.height];
        [_loadingIndicator addConstraint:heightConstraint];
        
        NSLayoutConstraint *widthConstraint =
        [NSLayoutConstraint constraintWithItem:_loadingIndicator
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1.0
                                      constant:_loadingIndicator.frame.size.width];
        [_loadingIndicator addConstraint:widthConstraint];
        
        _loadingDimmingView = [[UIView alloc] initWithFrame:[self keyWindow].bounds];
        _loadingDimmingView.backgroundColor = [UIColor blackColor];
        _loadingDimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _loadingDimmingView.opaque = NO;
        _loadingDimmingView.alpha = 0.7f;
        [_loadingDimmingView addSubview:_loadingIndicator];
        _loadingIndicator.center = _loadingDimmingView.center;
    }
    
    return _loadingDimmingView;
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
    UIView * indicatorView = [UIViewController indicatorView];
    UIWindow * window = [UIViewController keyWindow];
    [window addSubview:indicatorView];
    
    if(_loadingIndicator) {
        [_loadingIndicator startAnimating];
    }
}

- (void)hideActivityIndicator {
    if(_loadingIndicator) {
        [_loadingIndicator stopAnimating];
    }
    
    UIView * indicatorView = [UIViewController indicatorView];
    [indicatorView removeFromSuperview];
}

@end
