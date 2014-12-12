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
