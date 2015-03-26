//
//  UIBarButtonItem+CustomBadgeView.m
//  IQ300
//
//  Created by Tayphoon on 18.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <objc/runtime.h>

#import "UITabBarItem+CustomBadgeView.h"

NSString const *UITabBarItem_badgeViewKey = @"UITabBarItem_badgeViewKey";
NSString const *UITabBarItem_badgeOriginKey = @"UITabBarItem_badgeOriginKey";
NSString const *UITabBarItem_badgeInternalValueKey = @"UITabBarItem_badgeOriginKey";

@implementation UITabBarItem(CustomBadgeView)

+ (void)initialize {
    Method originalMethod = class_getInstanceMethod(self, @selector(setBadgeValue:));
    Method overrideMethod = class_getInstanceMethod(self, @selector(setBadgeValueSwizzled:));
    method_exchangeImplementations(originalMethod, overrideMethod);
    
    originalMethod = class_getInstanceMethod(self, @selector(badgeValue));
    overrideMethod = class_getInstanceMethod(self, @selector(badgeValueSwizzled));
    method_exchangeImplementations(originalMethod, overrideMethod);
}

- (void)setCustomBadgeView:(UIView *)customBadgeView {
    UIView * oldBadgeView = self.customBadgeView;
    [oldBadgeView removeFromSuperview];
    
    objc_setAssociatedObject(self, &UITabBarItem_badgeViewKey, customBadgeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if(customBadgeView) {
        [self setBadgeValueSwizzled:nil];
        [self updateBadgeFrame];
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
        [self updateBadgeFrame];
    }
}

- (void)setBadgeValueSwizzled:(NSString*)badgeValue {
    UIView * customBadgeView = self.customBadgeView;
    if(customBadgeView) {
        [self setBadgeValueSwizzled:nil];
        [self setInternalBadgeValue:badgeValue];
        [customBadgeView setHidden:([badgeValue length] == 0)];
        [self updateBadgeFrame];
    }
    else {
        [self setBadgeValueSwizzled:badgeValue];
    }
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

- (void)updateBadgeFrame {
    UIView * badgeView = self.customBadgeView;
    
    UIView * parentView = [self valueForKey:@"view"];
    if (badgeView.superview == nil) {
        [parentView.superview addSubview:badgeView];
    }
    
    if([badgeView respondsToSelector:@selector(setBadgeValue:)]) {
        [badgeView performSelector:@selector(setBadgeValue:)
                        withObject:[self internalBadgeValue]];
    }
    
    CGPoint badgeOrigin = self.badgeOrigin;
    badgeOrigin = CGPointMake(parentView.frame.origin.x + badgeOrigin.x,
                              parentView.frame.origin.y + badgeOrigin.y);
    
    CGSize expectedBadgeSize = badgeView.frame.size;
    badgeView.frame = CGRectMake(badgeOrigin.x, badgeOrigin.y, expectedBadgeSize.width, expectedBadgeSize.height);
    badgeView.layer.masksToBounds = YES;
}

@end
