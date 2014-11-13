//
//  NSBundle+Localization.m
//  IQ300
//
//  Created by Tayphoon on 10.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "NSBundle+Localization.h"

@implementation NSBundle (Localization)

+ (NSBundle*)localizedBundle {
    NSString *lang = [NSLocale preferredLanguages].firstObject;
    if (![lang isEqualToString:@"ru"]) {
        lang = @"en";
    }
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:lang ofType:@"lproj"]];
}

@end
