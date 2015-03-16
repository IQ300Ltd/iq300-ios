//
//  IQLayoutManager.m
//  IQ300
//
//  Created by Tayphoon on 10.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "IQLayoutManager.h"

NSString * const IQNikStrokeColorAttributeName = @"IQSpecialHighlightAttributeName";
NSString * const IQNikBackgroundColorAttributeName = @"IQNikBackgroundColorAttributeName";

@implementation IQLayoutManager

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    NSTextStorage * textStorage = self.textStorage;
    NSRange glyphRange = glyphsToShow;
    NSTextContainer *textContainer = self.textContainers[0];
    
    while (glyphRange.length > 0) {
        NSRange attributeCharRange;
        NSRange attributeGlyphRange;
        
        NSRange charRange = [self characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
        
        id backgroundAttribute = [textStorage attribute:IQNikBackgroundColorAttributeName
                                                atIndex:charRange.location longestEffectiveRange:&attributeCharRange
                                                inRange:charRange];
        attributeGlyphRange = [self glyphRangeForCharacterRange:attributeCharRange actualCharacterRange:NULL];
        attributeGlyphRange = NSIntersectionRange(attributeGlyphRange, glyphRange);
        if(backgroundAttribute != nil) {
            CGRect boundingRect = [self boundingRectForGlyphRange:attributeGlyphRange inTextContainer:textContainer];
            boundingRect.origin.y += 0.5f;
            
            [self drawRoundedRectWithStrokeColor:backgroundAttribute backgroundColor:backgroundAttribute boundingRect:boundingRect];
            [super drawGlyphsForGlyphRange:attributeGlyphRange atPoint:origin];
        }
        else {
            [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
        }
        
        id strokeAttribute = [textStorage attribute:IQNikStrokeColorAttributeName
                                      atIndex:charRange.location
                              longestEffectiveRange:&attributeCharRange
                                      inRange:charRange];
        
        attributeGlyphRange = [self glyphRangeForCharacterRange:attributeCharRange actualCharacterRange:NULL];
        attributeGlyphRange = NSIntersectionRange(attributeGlyphRange, glyphRange);


        if(strokeAttribute != nil) {
            CGRect boundingRect = [self boundingRectForGlyphRange:attributeGlyphRange inTextContainer:textContainer];
            boundingRect.origin.y += 0.5f;

            [self drawRoundedRectWithStrokeColor:strokeAttribute backgroundColor:[UIColor clearColor] boundingRect:boundingRect];
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
    if (backgroundColor != nil) {
        [backgroundColor setFill]; // set rounded rect's bg color
    }
    
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:boundingRect cornerRadius:2.5];
    [roundedRect fillWithBlendMode: kCGBlendModeNormal alpha:1.0f];
    
    if(strokeColor != nil) {
        [strokeColor setStroke]; // set rounded rect's stroke color
    }
    
    [roundedRect strokeWithBlendMode:kCGBlendModeNormal alpha:1.0f];
}

@end
