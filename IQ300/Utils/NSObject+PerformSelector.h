//
//  NSObject+PerformSelector.h
//  OBI
//
//  Created by Tayphoon on 22.05.13.
//  Copyright (c) 2013 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PerformSelector)

- (void)performSelector:(SEL)selector withObjects:(id)firstObj, ...;
- (void)performSelector:(SEL)selector afterDelay:(NSTimeInterval)delay withObjects:(id)firstObj, ...;

@end
