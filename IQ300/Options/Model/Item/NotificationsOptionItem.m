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
        _onState = YES;
    }
    
    return self;
}

+ (instancetype)itemWithOnState:(BOOL)onState {
    NotificationsOptionItem *item = [[NotificationsOptionItem alloc] init];
    item.onState = onState;
    
    return item;
}

@end
