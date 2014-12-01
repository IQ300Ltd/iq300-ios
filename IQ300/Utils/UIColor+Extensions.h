//
//  UIColor+RandomColor.h
//  OBI
//
//  Created by Tayphoon on 23.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor(Extensions)

+ (UIColor*)randomColor;

+ (UIColor*)colorWithHexInt:(int) hexColor; //converts color from hex int to UIColor

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue; //converts RGB to UIColor

+ (UIColor *)colorWithHexString:(NSString *)hexString;//converts color from hex string to UIColor

+ (UIColor *)grayPaperColor;

+ (UIColor *)bluePaperColor;

+ (UIColor *)greenPaperColor;

+ (UIColor *)yellowPaperColor;

+ (UIColor *)orangePaperColor;

+ (UIColor *)purplePaperColor;

+ (UIColor *)yellowCustomColor;

+ (UIColor *)blueCustomColor;

+ (UIColor *)blueUsualColor;

+ (UIColor *)greenCustomColor;

+ (UIColor *)purpleCustomColor;

+ (UIColor *)redCustomColor;

+ (UIColor *)cherryCustomColor;

+ (UIColor *)burlywoodCustomColor;

+ (UIColor *)tanCustomColor;

+ (UIColor *)goldenHighlight;

+ (UIColor *)redWarmColor;

+ (UIColor *)blackWarmColor;

+ (UIColor *)blackDeepWarmColor;

+ (UIColor *)silverColor;

+ (UIColor *)customGrayColor;

+ (UIColor *)magentaCustomColor;

+ (UIColor *)deepBlueCustomColor;

+ (UIColor *)lightBlueColor;

+ (UIColor *)deepColdBlueColor;

+ (UIColor *)skyBlueColor;

+ (UIColor *)lightGreenColor;

+ (UIColor *)warmGreenColor;

+ (UIColor *)deepGreenColor;

+ (UIColor *)goldColor;

#pragma mark - Standart Colors:

+ (UIColor *)stdSelectedColor;

+ (UIColor *)stdRedLineColor;

@end
