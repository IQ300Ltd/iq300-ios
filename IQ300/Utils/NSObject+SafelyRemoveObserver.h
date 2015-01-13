//
//  NSObject+SafelyRemoveObserver.h
//  OBI
//
//  Created by Tayphoon on 18.01.13.
//  Copyright (c) 2013 Tayphoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SafelyRemoveObserver)

- (void)safelyRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end
