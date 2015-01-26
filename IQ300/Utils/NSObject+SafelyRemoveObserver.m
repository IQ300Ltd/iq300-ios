//
//  NSObject+SafelyRemoveObserver.m
//  OBI
//
//  Created by Tayphoon on 18.01.13.
//  Copyright (c) 2013 Tayphoon. All rights reserved.
//

#import "NSObject+SafelyRemoveObserver.h"

@implementation NSObject (SafelyRemoveObserver)

- (void)safelyRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    @try{
        [self removeObserver:observer forKeyPath:keyPath];
    }@catch(id anException){
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
}

@end
