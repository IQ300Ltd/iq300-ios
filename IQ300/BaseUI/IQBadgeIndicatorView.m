//
//  IQBadgeIndicatorView.m
//  IQ300
//
//  Created by Tayphoon on 28.04.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQBadgeIndicatorView.h"

@implementation IQBadgeIndicatorView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, [self.badgeColor CGColor]);
    CGContextFillEllipseInRect(context, rect);
    CGContextRestoreGState(context);
}

@end
