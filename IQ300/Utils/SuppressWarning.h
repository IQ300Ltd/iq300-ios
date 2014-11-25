//
//  SuppressWarning.h
//  OBI
//
//  Created by Tayphoon on 14.01.13.
//  Copyright (c) 2013 Tayphoon. All rights reserved.
//

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)
