//
//  IQOnlineIndicator.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 05/04/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "IQOnlineIndicator.h"

@implementation IQOnlineIndicator

+ (UIColor *)colorForStyle:(IQOnlineIndicatorStyle)style online:(BOOL)online {
    static NSDictionary *colors = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        colors = @{
                   @(IQOnlineIndicatorStyleUser) : @{
                           @(YES) : [UIColor colorWithHexInt:0x3AB54A],
                           @(NO) : [UIColor clearColor],
                           },
                   @(IQOnlineIndicatorStyleCurrentUser) : @{
                           @(YES) : [UIColor colorWithHexInt:0x3AB54A],
                           @(NO) : [UIColor colorWithHexInt:0xB3B3B3],
                           }
                   };
    });
    return [[colors objectForKey:@(style)] objectForKey:@(online)];
}

+ (UIColor *)borderColorForStyle:(IQOnlineIndicatorStyle)style online:(BOOL)online {
    static NSDictionary *borderColors = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        borderColors = @{
                   @(IQOnlineIndicatorStyleUser) : @{
                           @(YES) : [UIColor clearColor],
                           @(NO) : [UIColor clearColor],
                           },
                   @(IQOnlineIndicatorStyleCurrentUser) : @{
                           @(YES) : [UIColor whiteColor],
                           @(NO) : [UIColor whiteColor],
                           }
                   };
    });
    return [[borderColors objectForKey:@(style)] objectForKey:@(online)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _style = IQOnlineIndicatorStyleUser;
        _online = NO;
        _borderWidht = 0.5f;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setOnline:(BOOL)online {
    _online = online;
    [self setNeedsDisplay];
}

- (void)setStyle:(IQOnlineIndicatorStyle)style {
    _style = style;
    [self setNeedsDisplay];
}

- (void)setBorderWidht:(CGFloat)borderWidht {
    _borderWidht = borderWidht;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect borderRect = CGRectInset(rect, _borderWidht * 0.5, _borderWidht * 0.5);
    
    CGContextSetFillColorWithColor(context, [IQOnlineIndicator colorForStyle:_style online:_online].CGColor);
    CGContextSetStrokeColorWithColor(context, [IQOnlineIndicator borderColorForStyle:_style online:_online].CGColor);
    CGContextSetLineWidth(context, _borderWidht);
    
    CGContextFillEllipseInRect(context, borderRect);
    CGContextStrokeEllipseInRect(context, borderRect);
}

@end
