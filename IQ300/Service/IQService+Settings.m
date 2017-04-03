//
//  IQService+Settings.m
//  IQ300
//
//  Created by Viktor Sabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "IQService+Settings.h"

@implementation IQService (Settings)

- (void)pushNotificationsSettingsWithHandler:(ObjectRequestCompletionHandler)handler {
    [self getObjectsAtPath:@"users/settings"
                parameters:nil
                   handler:handler];
}

- (void)makePushNotificationsEnabled:(BOOL)enabled handler:(ObjectRequestCompletionHandler)handler {
    
}

@end
