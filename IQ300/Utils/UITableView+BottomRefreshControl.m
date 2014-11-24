//
//  UITableView+BottomRefreshControl.m
//  IQ300
//
//  Created by Tayphoon on 24.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <objc/runtime.h>

#import "UITableView+BottomRefreshControl.h"

static void * const kRefreshControlStorageKey = (void*)&kRefreshControlStorageKey;

@implementation UIScrollView (BottomRefreshControl)

+ (void)load {
    Method originalMethod = class_getInstanceMethod(self, @selector(setContentOffset:));
    Method overrideMethod = class_getInstanceMethod(self, @selector(setContentOffsetSwizzled:));
    method_exchangeImplementations(originalMethod, overrideMethod);
    
    originalMethod = class_getInstanceMethod(self, @selector(setContentSize:));
    overrideMethod = class_getInstanceMethod(self, @selector(setContentSizeSwizzled:));
    method_exchangeImplementations(originalMethod, overrideMethod);
}

- (void)setContentOffsetSwizzled:(CGPoint)contentOffset {
    [self setContentOffsetSwizzled:contentOffset];
    
    if ((self.contentOffset.y + self.frame.size.height) >= self.contentSize.height + 50) {
        NSLog(@"End of the world");
    }
}

- (void)setBottomRefreshControl:(UIRefreshControl *)bottomRefreshControl {
    [self willChangeValueForKey:@"bottomRefreshControl"];
    objc_setAssociatedObject(self, kRefreshControlStorageKey, bottomRefreshControl, OBJC_ASSOCIATION_ASSIGN);
    [self addSubview:bottomRefreshControl];
    CGRect newFrame = bottomRefreshControl.frame;
    newFrame.origin.y = self.contentSize.height;
    [bottomRefreshControl setFrame:newFrame];
    [self didChangeValueForKey:@"bottomRefreshControl"];
}

- (void)setContentSizeSwizzled:(CGSize)contentSize {
    [self setContentSizeSwizzled:contentSize];
    
    UIRefreshControl * bottomRefreshControl = self.bottomRefreshControl;
    CGRect newFrame = bottomRefreshControl.frame;
    newFrame.origin.y = self.contentSize.height;
    [bottomRefreshControl setFrame:newFrame];
}

- (UIRefreshControl*)bottomRefreshControl {
    return objc_getAssociatedObject(self, kRefreshControlStorageKey);
}

//- (void)_notifyDidScroll {
//    
//}


@end
