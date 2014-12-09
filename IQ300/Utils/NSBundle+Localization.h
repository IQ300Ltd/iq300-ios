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

#if defined(NSLocalizedStringFromTable)
#undef NSLocalizedStringFromTable
#endif

#define NSLocalizedString(key, comment) \
[[NSBundle localizedBundle] localizedStringForKey:(key) value:@"" table:nil]

#define NSLocalizedStringFromTable(key, tbl, comment) \
[[NSBundle localizedBundle] localizedStringForKey:(key) value:@"" table:tbl]

#define NSLocalizedStringWithFormat(key, args...) \
[NSString stringWithFormat:NSLocalizedString(key, nil), args]

@end
