//
//  UIView+RoundedCorners.m
//  OBI
//
//  Created by Tayphoon on 01.05.13.
//  Copyright (c) 2013 Tayphoon. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "UIView+RoundedCorners.h"

@implementation UIView (RoundedCorners)

- (void)setRoundingCornersMask:(UIRectCorner)corners {
    [self setRoundingCornersMask:corners withRadius:5.0];
}

- (void)setRoundingCornersMask:(UIRectCorner)corners withRadius:(CGFloat)radius{
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                  byRoundingCorners:corners
                                                        cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    shape.frame = self.bounds;
    self.layer.mask = shape;
}

@end
