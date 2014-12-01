//
//  IQBadgeView.m
//  IQ300
//
//  Created by Tayphoon on 25.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQBadgeView.h"

#define BADGE_MIN_SIZE 25

@implementation IQBadgeView
+ (CustomBadge*)customBadgeWithString:(NSString *)badgeString {
    BadgeStyle * style = [BadgeStyle defaultStyle];
    style.badgeTextColor = [UIColor colorWithHexInt:0x459dbe];
    style.badgeFrameColor = [UIColor colorWithHexInt:0x338cae];
    style.badgeInsetColor = [UIColor whiteColor];
    style.badgeFrame = YES;
   return [IQBadgeView customBadgeWithString:badgeString withScale:1.0 withStyle:style];
}

- (void)autoBadgeSizeWithString:(NSString *)badgeString {
    CGSize retValue;
    CGFloat rectWidth, rectHeight;
    NSDictionary *fontAttr = @{ NSFontAttributeName : [self fontForBadgeWithSize:12] };
    CGSize stringSize = [badgeString sizeWithAttributes:fontAttr];
    CGFloat flexSpace;
    if ([badgeString length]>2) {
        flexSpace = [badgeString length];
        rectWidth = BADGE_MIN_SIZE + (stringSize.width + flexSpace); rectHeight = BADGE_MIN_SIZE;
        retValue = CGSizeMake(rectWidth * badgeScaleFactor, rectHeight * badgeScaleFactor);
    } else {
        retValue = CGSizeMake(BADGE_MIN_SIZE * badgeScaleFactor, BADGE_MIN_SIZE * badgeScaleFactor);
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
    return [UIFont fontWithName:IQ_HELVETICA size:size];
}

@end
