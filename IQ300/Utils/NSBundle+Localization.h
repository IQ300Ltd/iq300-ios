//
//  NSBundle+Localization.h
//  IQ300
//
//  Created by Tayphoon on 10.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (Localization)

+ (NSBundle*)localizedBundle;

#if defined(NSLocalizedString)
#undef NSLocalizedString
#endif

#define NSLocalizedString(key, comment) \
[[NSBundle localizedBundle] localizedStringForKey:(key) value:@"" table:nil]

@end
