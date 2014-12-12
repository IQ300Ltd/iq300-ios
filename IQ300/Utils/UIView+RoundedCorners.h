//
//  UIView+RoundedCorners.h
//  OBI
//
//  Created by Tayphoon on 01.05.13.
//  Copyright (c) 2013 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RoundedCorners)

- (void)setRoundingCornersMask:(UIRectCorner)corners;
- (void)setRoundingCornersMask:(UIRectCorner)corners withRadius:(CGFloat)radius;

@end
