//
//  IQBadgeView.m
//  IQ300
//
//  Created by Tayphoon on 25.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQBadgeView.h"

#define BADGE_MIN_SIZE 25

@interface IQBadgeView() {
    UIFont * _badgeTextFont;
}

@end

@implementation IQBadgeView

+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString {
    return [self customBadgeWithString:badgeString badgeMinSize:BADGE_MIN_SIZE];;
}

+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString badgeMinSize:(CGFloat)badgeMinSize {
    IQBadgeStyle * style = [IQBadgeStyle defaultStyle];
    style.badgeTextColor = [UIColor colorWithHexInt:0x459dbe];
    style.badgeFrameColor = [UIColor colorWithHexInt:0x338cae];
    style.badgeInsetColor = [UIColor whiteColor];
    style.badgeFrame = YES;
    
    IQBadgeView * badge = [IQBadgeView customBadgeWithString:badgeString withStyle:style];
    badge.badgeMinSize = badgeMinSize;
    
   return badge;
}

+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString withScale:(CGFloat)scale {
    IQBadgeView * badgeView = [[self alloc] initWithString:badgeString withScale:scale withStyle:[IQBadgeStyle defaultStyle]];
    return badgeView;
}

+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString withStyle:(IQBadgeStyle*)style {
    IQBadgeView * badgeView = [[self alloc] initWithString:badgeString withScale:1.0f withStyle:style];
    return badgeView;
}

+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString withScale:(CGFloat)scale withStyle:(IQBadgeStyle*)style {
    IQBadgeView * badgeView = [[self alloc] initWithString:badgeString withScale:scale withStyle:style];
    badgeView.badgeScaleFactor = scale;
    return badgeView;
}

- (id)initWithString:(NSString *)badgeString withScale:(CGFloat)scale withStyle:(IQBadgeStyle*)style {
    self = [super initWithFrame:CGRectMake(0, 0, BADGE_MIN_SIZE, BADGE_MIN_SIZE)];
    if(self != nil) {
        _badgeValue = badgeString;
        _badgeMinSize = BADGE_MIN_SIZE;

        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        self.backgroundColor = [UIColor clearColor];
        self.badgeStyle = style;
        self.badgeCornerRoundness = 0.4;
        self.badgeScaleFactor = scale;
        self.frameLineHeight = 1.5f;
        [self autoBadgeSizeWithString:badgeString];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setBadgeValue:(NSString *)badgeValue {
    [self autoBadgeSizeWithString:badgeValue];
}

- (void)setBadgeMinSize:(CGFloat)badgeMinSize {
    if (_badgeMinSize != badgeMinSize) {
        _badgeMinSize = badgeMinSize;
        [self autoBadgeSizeWithString:self.badgeValue];
    }
}

- (void)setBadgeTextFont:(UIFont *)badgeTextFont {
    _badgeTextFont = badgeTextFont;
    [self autoBadgeSizeWithString:self.badgeValue];
}

- (UIFont*)badgeTextFont {
    if(!_badgeTextFont) {
        _badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:12];
    }
    return _badgeTextFont;
}

- (void)autoBadgeSizeWithString:(NSString *)badgeString {
    _badgeValue = badgeString;

    CGSize retValue;
    CGFloat rectWidth, rectHeight;
    NSDictionary *fontAttr = @{ NSFontAttributeName : [self fontForBadgeWithSize:12] };
    CGSize stringSize = [badgeString sizeWithAttributes:fontAttr];
    CGFloat flexSpace = 1.0f;
    
    if ([badgeString length] > 2) {
        flexSpace = -10;//[badgeString length];
        rectWidth = self.badgeMinSize + (stringSize.width + flexSpace);
        rectHeight = self.badgeMinSize;
        retValue = CGSizeMake(rectWidth * self.badgeScaleFactor, rectHeight * self.badgeScaleFactor);
    }
    else {
        retValue = CGSizeMake(self.badgeMinSize * self.badgeScaleFactor, self.badgeMinSize * self.badgeScaleFactor);
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, retValue.width, retValue.height);
    [self setNeedsDisplay];
}

- (void)drawFrameWithContext:(CGContextRef)context withRect:(CGRect)rect {
    CGFloat radius = CGRectGetMaxY(rect)*self.badgeCornerRoundness;
    CGFloat puffer = CGRectGetMaxY(rect)*0.10;
    
    CGFloat maxX = CGRectGetMaxX(rect) - puffer;
    CGFloat maxY = CGRectGetMaxY(rect) - puffer;
    CGFloat minX = CGRectGetMinX(rect) + puffer;
    CGFloat minY = CGRectGetMinY(rect) + puffer;
    
    
    CGContextBeginPath(context);
    CGFloat lineSize = self.frameLineHeight;
    if(self.badgeScaleFactor>1) {
        lineSize += self.badgeScaleFactor*0.25;
    }
    CGContextSetLineWidth(context, lineSize);
    CGContextSetStrokeColorWithColor(context, [self.badgeStyle.badgeFrameColor CGColor]);
    CGContextAddArc(context, maxX-radius, minY+radius, radius, M_PI+(M_PI/2), 0, 0);
    CGContextAddArc(context, maxX-radius, maxY-radius, radius, 0, M_PI/2, 0);
    CGContextAddArc(context, minX+radius, maxY-radius, radius, M_PI/2, M_PI, 0);
    CGContextAddArc(context, minX+radius, minY+radius, radius, M_PI, M_PI+M_PI/2, 0);
    CGContextClosePath(context);
    CGContextStrokePath(context);
}

- (void)drawShineWithContext:(CGContextRef)context withRect:(CGRect)rect {
    CGContextSaveGState(context);
    
    CGFloat radius = CGRectGetMaxY(rect)*self.badgeCornerRoundness;
    CGFloat puffer = CGRectGetMaxY(rect)*0.10;
    CGFloat maxX = CGRectGetMaxX(rect) - puffer;
    CGFloat maxY = CGRectGetMaxY(rect) - puffer;
    CGFloat minX = CGRectGetMinX(rect) + puffer;
    CGFloat minY = CGRectGetMinY(rect) + puffer;
    CGContextBeginPath(context);
    CGContextAddArc(context, maxX-radius, minY+radius, radius, M_PI+(M_PI/2), 0, 0);
    CGContextAddArc(context, maxX-radius, maxY-radius, radius, 0, M_PI/2, 0);
    CGContextAddArc(context, minX+radius, maxY-radius, radius, M_PI/2, M_PI, 0);
    CGContextAddArc(context, minX+radius, minY+radius, radius, M_PI, M_PI+M_PI/2, 0);
    CGContextClip(context);
    
    
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 0.4 };
    CGFloat components[8] = {  0.92, 0.92, 0.92, 1.0, 0.82, 0.82, 0.82, 0.4 };
    
    CGColorSpaceRef cspace;
    CGGradientRef gradient;
    cspace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents (cspace, components, locations, num_locations);
    
    CGPoint sPoint, ePoint;
    sPoint.x = 0;
    sPoint.y = 0;
    ePoint.x = 0;
    ePoint.y = maxY;
    CGContextDrawLinearGradient (context, gradient, sPoint, ePoint, 0);
    
    CGColorSpaceRelease(cspace);
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(context);	
}

- (void)drawRoundedRectWithContext:(CGContextRef)context withRect:(CGRect)rect {
    CGContextSaveGState(context);
    
    CGFloat radius = CGRectGetMaxY(rect)*self.badgeCornerRoundness;
    CGFloat puffer = CGRectGetMaxY(rect)*0.10;
    CGFloat maxX = CGRectGetMaxX(rect) - puffer;
    CGFloat maxY = CGRectGetMaxY(rect) - puffer;
    CGFloat minX = CGRectGetMinX(rect) + puffer;
    CGFloat minY = CGRectGetMinY(rect) + puffer;
    
    CGContextBeginPath(context);
    CGContextSetFillColorWithColor(context, [self.badgeStyle.badgeInsetColor CGColor]);
    CGContextAddArc(context, maxX-radius, minY+radius, radius, M_PI+(M_PI/2), 0, 0);
    CGContextAddArc(context, maxX-radius, maxY-radius, radius, 0, M_PI/2, 0);
    CGContextAddArc(context, minX+radius, maxY-radius, radius, M_PI/2, M_PI, 0);
    CGContextAddArc(context, minX+radius, minY+radius, radius, M_PI, M_PI+M_PI/2, 0);
    if (self.badgeStyle.badgeShadow) {
        CGContextSetShadowWithColor(context, CGSizeMake(1.0,1.0), 3, [[UIColor blackColor] CGColor]);
    }
    CGContextFillPath(context);
    CGContextRestoreGState(context);
}

- (UIFont*)fontForBadgeWithSize:(CGFloat)size {
    return self.badgeTextFont;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawRoundedRectWithContext:context withRect:rect];
    
    if(self.badgeStyle.badgeShining) {
        [self drawShineWithContext:context withRect:rect];
    }
    
    if (self.badgeStyle.badgeFrame)  {
        [self drawFrameWithContext:context withRect:rect];
    }
    
    if ([self.badgeValue length] > 0) {
        CGFloat sizeOfFont = 13.5 * _badgeScaleFactor;
        if ([self.badgeValue length] < 2) {
            sizeOfFont += sizeOfFont * 0.20f;
        }
        UIFont *textFont =  [self fontForBadgeWithSize:sizeOfFont];
        NSDictionary *fontAttr = @{ NSFontAttributeName : textFont, NSForegroundColorAttributeName : self.badgeStyle.badgeTextColor };
        CGSize textSize = [self.badgeValue sizeWithAttributes:fontAttr];
        CGPoint textPoint = CGPointMake((rect.size.width / 2.0f - textSize.width / 2.0f) + 0.5f,
                                        (rect.size.height / 2.0f - textSize.height / 2.0f) - 0.5f);
        [self.badgeValue drawAtPoint:textPoint withAttributes:fontAttr];
    }
}

@end
