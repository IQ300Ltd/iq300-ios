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
    return [self customBadgeWithString:badgeString badgeMinSize:BADGE_MIN_SIZE];
}

+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString badgeMinSize:(CGFloat)badgeMinSize {
    BadgeStyle * style = [BadgeStyle defaultStyle];
    style.badgeTextColor = [UIColor colorWithHexInt:0x459dbe];
    style.badgeFrameColor = [UIColor colorWithHexInt:0x338cae];
    style.badgeInsetColor = [UIColor whiteColor];
    style.badgeFrame = YES;
    
    IQBadgeView * badge = [IQBadgeView customBadgeWithString:badgeString withStyle:style];
    badge.badgeMinSize = badgeMinSize;
    
   return badge;
}

+ (IQBadgeView*)customBadgeWithString:(NSString *)badgeString withStyle:(BadgeStyle*)style {
    return (IQBadgeView*)[super customBadgeWithString:badgeString withStyle:style];
}

- (void)setBadgeMinSize:(CGFloat)badgeMinSize {
    if (_badgeMinSize != badgeMinSize) {
        _badgeMinSize = badgeMinSize;
        [self autoBadgeSizeWithString:self.badgeText];
    }
}

- (void)setBadgeTextFont:(UIFont *)badgeTextFont {
    _badgeTextFont = badgeTextFont;
    [self autoBadgeSizeWithString:self.badgeText];
}

- (UIFont*)badgeTextFont {
    if(!_badgeTextFont) {
        _badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:12];
    }
    return _badgeTextFont;
}

- (void)autoBadgeSizeWithString:(NSString *)badgeString {
    CGSize retValue;
    CGFloat rectWidth, rectHeight;
    NSDictionary *fontAttr = @{ NSFontAttributeName : [self fontForBadgeWithSize:12] };
    CGSize stringSize = [badgeString sizeWithAttributes:fontAttr];
    CGFloat flexSpace;
    if ([badgeString length]>2) {
        flexSpace = [badgeString length];
        rectWidth = self.badgeMinSize + (stringSize.width + flexSpace); rectHeight = self.badgeMinSize;
        retValue = CGSizeMake(rectWidth * badgeScaleFactor, rectHeight * badgeScaleFactor);
    } else {
        retValue = CGSizeMake(self.badgeMinSize * badgeScaleFactor, self.badgeMinSize * badgeScaleFactor);
    }
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, retValue.width, retValue.height);
    self.badgeText = badgeString;
    [self setNeedsDisplay];
}

- (void)drawFrameWithContext:(CGContextRef)context withRect:(CGRect)rect
{
    CGFloat radius = CGRectGetMaxY(rect)*self.badgeCornerRoundness;
    CGFloat puffer = CGRectGetMaxY(rect)*0.10;
    
    CGFloat maxX = CGRectGetMaxX(rect) - puffer;
    CGFloat maxY = CGRectGetMaxY(rect) - puffer;
    CGFloat minX = CGRectGetMinX(rect) + puffer;
    CGFloat minY = CGRectGetMinY(rect) + puffer;
    
    
    CGContextBeginPath(context);
    CGFloat lineSize = 1.5f;
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

- (UIFont*)fontForBadgeWithSize:(CGFloat)size {
    return self.badgeTextFont;
}

@end
