//
//  IQLayoutManager.m
//  IQ300
//
//  Created by Tayphoon on 10.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQLayoutManager.h"

NSString * const IQNikHighlightAttributeName = @"IQNikHighlightAttributeName";
NSString * const IQNikStrokeColorAttributeName = @"IQSpecialHighlightAttributeName";
NSString * const IQNikBackgroundColorAttributeName = @"IQNikBackgroundColorAttributeName";

@implementation IQLayoutManager

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    NSTextStorage * textStorage = self.textStorage;
    NSRange glyphRange = glyphsToShow;
    NSTextContainer *textContainer = self.textContainers[0];
    
    CGRect firstLineRect = [self lineFragmentRectForGlyphAtIndex:0 effectiveRange:nil];
    firstLineRect.size.height -= 0.5f;
    NSUInteger linesNumber = [self linesInText];

    while (glyphRange.length > 0) {
        NSRange attributeCharRange;
        NSRange attributeGlyphRange;
        
        NSRange charRange = [self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
        
        id highlightAttribute = [textStorage attribute:IQNikHighlightAttributeName
                                                atIndex:charRange.location longestEffectiveRange:&attributeCharRange
                                                inRange:charRange];
        attributeGlyphRange = [self glyphRangeForCharacterRange:attributeCharRange actualCharacterRange:NULL];
        attributeGlyphRange = NSIntersectionRange(attributeGlyphRange, glyphRange);
        
        if(highlightAttribute != nil) {
            UIColor * backgroundColor = [highlightAttribute objectForKey:IQNikBackgroundColorAttributeName];
            UIColor * strokeColor = [highlightAttribute objectForKey:IQNikStrokeColorAttributeName];
            
            CGRect boundingRect = [self boundingRectForGlyphRange:attributeGlyphRange inTextContainer:textContainer];
            boundingRect.origin.y += 0.5f;
            
            if (linesNumber > 1) {
                CGRect intersectionRect = CGRectIntersection(firstLineRect, boundingRect);
                
                if (CGRectIsNull(intersectionRect)) {
                    boundingRect.origin.y += 1.0f;
                    boundingRect.size.height -= 1.5f;
                }
                else {
                    boundingRect.size.height -= 0.5f;
                }
            }
            
            [self drawRoundedRectWithStrokeColor:strokeColor backgroundColor:backgroundColor boundingRect:boundingRect];
            [super drawGlyphsForGlyphRange:attributeGlyphRange atPoint:origin];
        }
        else {
            [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
        }
        
        glyphRange.length = NSMaxRange(glyphRange) - NSMaxRange(attributeGlyphRange);
        glyphRange.location = NSMaxRange(attributeGlyphRange);
    }
}

- (void)drawRoundedRectWithStrokeColor:(UIColor*)strokeColor backgroundColor:(UIColor*)backgroundColor boundingRect:(CGRect)boundingRect {
    if (backgroundColor == nil) {
        backgroundColor = [UIColor clearColor];
    }
  
    [backgroundColor setFill]; // set rounded rect's bg color

    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boundingRect cornerRadius:2.5];
    [roundedRect fillWithBlendMode: kCGBlendModeNormal alpha:1.0f];
    
    if(strokeColor == nil) {
        strokeColor = backgroundColor;
    }

    [strokeColor setStroke]; // set rounded rect's stroke color

    [roundedRect strokeWithBlendMode:kCGBlendModeNormal alpha:1.0f];
}

- (NSUInteger)linesInText {
    NSLayoutManager *layoutManager = self;
    NSTextContainer *textContainer = self.textContainers[0];
    NSRange glyphRange, lineRange = NSMakeRange(0, 0);
    CGRect rect;
    CGFloat lastOriginY = -1.0;
    NSUInteger numberOfLines = 0;
    
    glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
    while (lineRange.location < NSMaxRange(glyphRange))
    {
        rect = [layoutManager lineFragmentRectForGlyphAtIndex:lineRange.location effectiveRange:&lineRange];
        if (CGRectGetMinY(rect) > lastOriginY) ++numberOfLines;
        lastOriginY = CGRectGetMinY(rect);
        lineRange.location = NSMaxRange(lineRange);
    }
    return numberOfLines;
}

@end
