//
//  NSString+SizeWith.h
//  IQ300
//
//  Created by Tayphoon on 21.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SizeWith)

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (CGSize)sizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(NSLineBreakMode)lineBreakMode;
- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGSize)sizeWithFont:(UIFont *)font;

@end
