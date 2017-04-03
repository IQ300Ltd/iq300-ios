//
//  NotificationsOptionItem.m
//  IQ300
//
//  Created by Viktor Sabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "NotificationsOptionItem.h"

@implementation NotificationsOptionItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _titleString = NSLocalizedString(@"Notifications", nil);
        _onState = NO;
        _enabled = YES;
    }
    
    return self;
}

+ (instancetype)itemWithEnabled:(BOOL)enabled {
    return [self itemWithOnState:NO
                         enabled:enabled];
}

+ (instancetype)itemWithOnState:(BOOL)onState enabled:(BOOL)enabled {
    NotificationsOptionItem *item = [[NotificationsOptionItem alloc] init];
    item.onState = onState;
    item.enabled = enabled;
    
    return item;
}

@end
