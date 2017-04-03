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
        _enabledInteractions = YES;
    }
    
    return self;
}

+ (instancetype)itemWithEnabledInteractions:(BOOL)enabled {
    return [self itemWithOnState:NO enabledInteractions:enabled];
}
+ (instancetype)itemWithOnState:(BOOL)onState enabledInteractions:(BOOL)enabled {
    NotificationsOptionItem *item = [[NotificationsOptionItem alloc] init];
    item.onState = onState;
    item.enabledInteractions = enabled;
    
    return item;
}

@end
