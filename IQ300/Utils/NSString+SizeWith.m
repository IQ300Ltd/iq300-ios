//
//  NSString+SizeWith.m
//  IQ300
//
//  Created by Tayphoon on 21.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "NSString+SizeWith.h"

@implementation NSString (SizeWith)

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    NSDictionary * attributes = @{NSFontAttributeName : font,
                                  NSParagraphStyleAttributeName : paragraphStyle};
    
    return [self boundingRectWithSize:size
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:attributes
                              context:nil].size;
}

- (CGSize)sizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode {
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    NSDictionary * attributes = @{NSFontAttributeName : font,
                                  NSParagraphStyleAttributeName : paragraphStyle};
    
    return [self boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:attributes
                              context:nil].size;
}

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size {
    NSDictionary * attributes = @{NSFontAttributeName : font};
    
    return [self boundingRectWithSize:size
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:attributes
                              context:nil].size;
}

- (CGSize)sizeWithFont:(UIFont *)font {
    return [self sizeWithAttributes:@{ NSFontAttributeName : font }];
}

@end
