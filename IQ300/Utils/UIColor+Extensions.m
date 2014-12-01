//
//  UIColor+RandomColor.m
//  OBI
//
//  Created by Tayphoon on 23.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "UIColor+Extensions.h"

@implementation UIColor(Extensions)

+ (UIColor *) randomColor  {
    // GOAL: reject colors that are too dark
    float total = 3;
    float one = arc4random() % 256 / 256.0;
    total -= one;
    float two = arc4random() % 256 / 256.0;
    total -= two;
    float three = total; // UIColor will chop out-of-range nums
    
    NSMutableArray *threeFloats = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithFloat:one], [NSNumber numberWithFloat:two], [NSNumber numberWithFloat:three], nil];
    
    NSNumber *red, *green, *blue;
    red = [threeFloats objectAtIndex:arc4random() % [threeFloats count]];
    [threeFloats removeObject:red];
    green = [threeFloats objectAtIndex:arc4random() % [threeFloats count]];
    [threeFloats removeObject:green];
    blue = [threeFloats lastObject];
    
    return [UIColor colorWithRed:[red floatValue] green:[green floatValue] blue:[blue floatValue] alpha:1];
}

+ (UIColor*) colorWithHexInt:(int)hexColor {
    return [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0 green:((float)((hexColor & 0xFF00) >> 8))/255.0 blue:((float)(hexColor & 0xFF))/255.0 alpha:1.0];
}

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor blackColor];
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:r green:g blue:b];
}

+ (UIColor *)grayPaperColor {
    return [UIColor colorWithHexInt:0xefefef];
}
+ (UIColor *)bluePaperColor {
    return [UIColor colorWithHexInt:0xdceffc];
}

+ (UIColor *)greenPaperColor {
    return [UIColor colorWithHexInt:0xf1fbd1];
}

+ (UIColor *)yellowPaperColor {
    return [UIColor colorWithHexInt:0xfef1b9];
}

+ (UIColor *)orangePaperColor {
    return [UIColor colorWithHexInt:0xf8dfc9];
}

+ (UIColor *)purplePaperColor {
    return [UIColor colorWithHexInt:0xc5d1f1];
}

+ (UIColor *)yellowCustomColor {
    return [UIColor colorWithRed:248/255.0 green:255/255.0 blue:173/255.0 alpha:1];
}

+ (UIColor *)blueCustomColor {
    return [UIColor colorWithRed:130/255.0 green:210/255.0 blue:247/255.0 alpha:1];
}

+ (UIColor *)blueUsualColor
{
    return [UIColor colorWithHexInt:0x224062];
}

+ (UIColor *)greenCustomColor {
    return [UIColor colorWithRed:208/255.0 green:254/255.0 blue:227/255.0 alpha:1];
}

+ (UIColor *)purpleCustomColor {
    return [UIColor colorWithRed:250/255.0 green:211/255.0 blue:254/255.0 alpha:1];
}

+ (UIColor *)redCustomColor {
    return [UIColor colorWithRed:252/255.0 green:164/255.0 blue:179/255.0 alpha:1];
}

+ (UIColor *)cherryCustomColor
{
    return [UIColor colorWithRed:202/255.0 green:22/255.0 blue:39/255.0 alpha:1.0];
}

+ (UIColor *)burlywoodCustomColor {
    return [UIColor colorWithRed:222/255.0 green:184/255.0 blue:135/255.0 alpha:1];
}

+ (UIColor *)tanCustomColor {
    return [UIColor colorWithRed:210/255.0 green:180/255.0 blue:140/255.0 alpha:1];
}

+ (UIColor *)goldenHighlight {
    return [UIColor colorWithRed:251/255.0 green:255/255.0 blue:207/255.0 alpha:1];
}

+ (UIColor *)redWarmColor {
    return [UIColor colorWithRed:255/255.0 green:78/255.0 blue:81/255.0 alpha:1];
}

+ (UIColor *)blackWarmColor {
    return [UIColor colorWithRed:65/255.0 green:65/255.0 blue:67/255.0 alpha:1];
}

+ (UIColor *)blackDeepWarmColor {
    return [UIColor colorWithRed:48/255.0 green:49/255.0 blue:55/255.0 alpha:1];
}

+ (UIColor *)silverColor {
    return [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
}

+ (UIColor *)customGrayColor {
    return [UIColor colorWithRed:214/255.0 green:213/255.0 blue:215/255.0 alpha:1];
}

+ (UIColor *)magentaCustomColor {
    return [UIColor colorWithRed:202/255.0 green:31/255.0 blue:123/255.0 alpha:1];
}

+ (UIColor *)deepBlueCustomColor {
    return [UIColor colorWithRed:4/255.0 green:115/255.0 blue:232/255.0 alpha:1];
}

+ (UIColor *)lightBlueColor {
    return [UIColor colorWithRed:111.0f/255.0f green:179/255.0f blue:208.0f/230 alpha:1.0f];
}

+ (UIColor *)deepColdBlueColor
{
    return [UIColor colorWithRed:81/255.0 green:95/255.0 blue:139/255.0 alpha:1.0];
}

+ (UIColor *)skyBlueColor
{
    return [UIColor colorWithRed:24 green:111 blue:203];
}

+ (UIColor *)lightGreenColor {
    return [UIColor colorWithRed:186/255.0 green:212/255.0 blue:99/255.0 alpha:1];
}

+ (UIColor *)warmGreenColor
{
    return [UIColor colorWithRed:72 green:135 blue:34];
}

+ (UIColor *)deepGreenColor {
    return [UIColor colorWithRed:57/255.0 green:114/255.0 blue:68/255.0 alpha:1];
}

+ (UIColor *)goldColor {
    return [UIColor colorWithRed:255/255.0 green:226/255.0 blue:127/255.0 alpha:1];
}

#pragma mark - Standart Colors:

+ (UIColor *)stdSelectedColor
{
    return [UIColor colorWithHexInt:0x0892f0];
}

+ (UIColor *)stdRedLineColor
{
    return [UIColor colorWithHexInt:0xaf1c2d];
}

#pragma mark - UI

@end
