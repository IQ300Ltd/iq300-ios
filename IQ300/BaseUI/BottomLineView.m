//
//  ViewBottomLine.m
//  IQ300
//
//  Created by Tayphoon on 10.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "BottomLineView.h"

@implementation BottomLineView

- (void)drawRect:(CGRect)rect {
    CGContextRef contex = UIGraphicsGetCurrentContext();
    
    CGRect bottomLine = CGRectMake(rect.origin.x,
                                   rect.origin.y + rect.size.height - _bottomLineHeight + 0.5f,
                                   rect.size.width,
                                   _bottomLineHeight);
    
    //Draw bottom line
    CGContextSetStrokeColorWithColor(contex, [_bottomLineColor CGColor]);
    CGContextSetLineWidth(contex, _bottomLineHeight);
    CGContextStrokeRect(contex, bottomLine);
}

@end
