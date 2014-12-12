//
//  NSBundle+Localization.m
//  IQ300
//
//  Created by Tayphoon on 10.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "NSBundle+Localization.h"

#define DEFAULT_LOCALIZATION @"en"

@implementation NSBundle (Localization)

+ (NSBundle*)localizedBundle {

#ifndef USE_DEFAULT_LOCALIZATION
    NSArray * supportedLocale = [[NSBundle mainBundle] localizations];
    NSString *lang = [NSLocale preferredLanguages].firstObject;
    if (![supportedLocale containsObject:lang]) {
        lang = DEFAULT_LOCALIZATION;
    }
#else
    NSString * lang = @"ru";
#endif

    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:lang ofType:@"lproj"]];
}

@end
