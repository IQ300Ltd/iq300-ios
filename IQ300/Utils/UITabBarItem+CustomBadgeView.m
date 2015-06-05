//
//  UIBarButtonItem+CustomBadgeView.m
//  IQ300
//
//  Created by Tayphoon on 18.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <objc/runtime.h>

#import "UITabBarItem+CustomBadgeView.h"
#import "NSObject+SafelyRemoveObserver.h"

NSString const *UITabBarItem_badgeViewKey = @"UITabBarItem_badgeViewKey";
NSString const *UITabBarItem_badgeOriginKey = @"UITabBarItem_badgeOriginKey";
NSString const *UITabBarItem_badgeInternalValueKey = @"UITabBarItem_badgeOriginKey";

@interface UITabBarItem(Private)

@property(retain) UIView * view;

@end

@implementation UITabBarItem(CustomBadgeView)

+ (void)initialize {
    Method originalMethod = class_getInstanceMethod(self, @selector(setBadgeValue:));
    Method overrideMethod = class_getInstanceMethod(self, @selector(setBadgeValueSwizzled:));
    method_exchangeImplementations(originalMethod, overrideMethod);
    
    originalMethod = class_getInstanceMethod(self, @selector(badgeValue));
    overrideMethod = class_getInstanceMethod(self, @selector(badgeValueSwizzled));
    method_exchangeImplementations(originalMethod, overrideMethod);
    
    originalMethod = class_getInstanceMethod(self, @selector(setView:));
    overrideMethod = class_getInstanceMethod(self, @selector(setViewSwizzled:));
    method_exchangeImplementations(originalMethod, overrideMethod);
}

- (void)setCustomBadgeView:(UIView *)customBadgeView {
    UIView * oldBadgeView = self.customBadgeView;
    if (oldBadgeView) {
        [oldBadgeView removeFromSuperview];
        UIView * parentView = self.view;
        [parentView safelyRemoveObserver:self forKeyPath:@"frame"];
    }
    
    if(customBadgeView) {
        NSString * badgeValue = [self internalBadgeValue];
        customBadgeView.hidden = ([badgeValue length] == 0);
        objc_setAssociatedObject(self, &UITabBarItem_badgeViewKey, customBadgeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self setBadgeValueSwizzled:nil];
    }
}

- (UIView*)customBadgeView {
    return objc_getAssociatedObject(self, &UITabBarItem_badgeViewKey);
}

- (CGPoint)badgeOrigin {
    CGPoint badgeOrigin;
    
    NSValue * origin = objc_getAssociatedObject(self, &UITabBarItem_badgeOriginKey);
    [origin getValue:&badgeOrigin];
    
    return (!origin) ? CGPointZero :  badgeOrigin;
}

- (void)setBadgeOrigin:(CGPoint)badgeOrigin {
    NSValue * origin = [NSValue valueWithBytes:&badgeOrigin objCType:@encode(CGPoint)];
    objc_setAssociatedObject(self, &UITabBarItem_badgeOriginKey, origin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.customBadgeView) {
        [self updateBadge];
    }
}

- (void)setBadgeValueSwizzled:(NSString*)badgeValue {
    UIView * customBadgeView = self.customBadgeView;
    if(customBadgeView) {
        [self setBadgeValueSwizzled:nil];
        [self setInternalBadgeValue:badgeValue];
        customBadgeView.hidden = ([badgeValue length] == 0);
        [self updateBadge];
    }
    else {
        [self setBadgeValueSwizzled:badgeValue];
    }
}

- (void)setViewSwizzled:(UIView*)view {
    [self.view safelyRemoveObserver:self forKeyPath:@"frame"];
    UIView * badgeView = self.customBadgeView;
    [badgeView removeFromSuperview];
    
    [self setViewSwizzled:view];
    [self updateBadge];
}

- (NSString*)badgeValueSwizzled {
    UIView * customBadgeView = self.customBadgeView;
    if(customBadgeView) {
        return [self internalBadgeValue];
    }
    return [self badgeValueSwizzled];
}

- (NSString*)internalBadgeValue {
    return objc_getAssociatedObject(self, &UITabBarItem_badgeInternalValueKey);
}

- (void)setInternalBadgeValue:(NSString*)badgeValue {
    objc_setAssociatedObject(self, &UITabBarItem_badgeInternalValueKey, badgeValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)updateBadge {
    UIView * badgeView = self.customBadgeView;
    UIView * parentView = self.view;

    if (badgeView.superview == nil && parentView.superview) {
        [parentView.superview addSubview:badgeView];
        [parentView safelyRemoveObserver:self forKeyPath:@"frame"];
        [parentView addObserver:self forKeyPath:@"frame" options:0 context:nil];
    }
    
    if([badgeView respondsToSelector:@selector(setBadgeValue:)]) {
        [badgeView performSelector:@selector(setBadgeValue:)
                        withObject:[self internalBadgeValue]];
    }
    
    CGPoint badgeOrigin = self.badgeOrigin;
    
    badgeOrigin = CGPointMake(parentView.frame.origin.x + (parentView.frame.size.width) / 2.0f + badgeOrigin.x,
                              parentView.frame.origin.y + badgeOrigin.y);
    
    CGSize expectedBadgeSize = badgeView.frame.size;
    badgeView.frame = CGRectMake(badgeOrigin.x, badgeOrigin.y, expectedBadgeSize.width, expectedBadgeSize.height);
    badgeView.layer.masksToBounds = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        [self updateBadge];
    }
}

- (void)dealloc {
    UIView * parentView = self.view;
    [parentView safelyRemoveObserver:self forKeyPath:@"frame"];
}

@end
