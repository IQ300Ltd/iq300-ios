//
//  IQMenuSection.m
//  IQ300
//
//  Created by Tayphoon on 10.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import "IQMenuSection.h"

@interface IQMenuSection() {
    NSMutableArray * _menuItems;
}

@end

@implementation IQMenuSection

- (id)init {
    self = [super init];
    
    if (self) {
        _menuItems = [NSMutableArray array];
    }
    
    return self;
}


- (NSArray*)menuItems {
    return [_menuItems copy];
}

- (void)addItem:(IQMenuItem*)item {
    [_menuItems addObject:item];
}

- (void)removeItem:(IQMenuItem*)item {
    [_menuItems removeObject:item];
}

@end
