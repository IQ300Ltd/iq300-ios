//
//  UIEdgeInsetsExtend.h
//  OBI
//
//  Created by Tayphoon on 17.12.13.
//  Copyright (c) 2013 Tayphoon. All rights reserved.
//

#import <UIKit/UIKitDefines.h>

UIKIT_STATIC_INLINE UIEdgeInsets UIEdgeInsetsMakeWithInset(CGFloat inset) {
    UIEdgeInsets insets = {inset, inset, inset, inset};
    return insets;
}

UIKIT_STATIC_INLINE UIEdgeInsets UIEdgeInsetsVerticalMake(CGFloat inset) {
    UIEdgeInsets insets = {0.0f, inset, 0.0f, inset};
    return insets;
}

UIKIT_STATIC_INLINE UIEdgeInsets UIEdgeInsetsHorizontalMake(CGFloat inset) {
    UIEdgeInsets insets = {inset, 0.0f, inset, 0.0f};
    return insets;
}