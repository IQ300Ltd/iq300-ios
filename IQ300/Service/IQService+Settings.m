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
                   handler:^(BOOL success, NSArray *object, NSData *responseData, NSError *error) {
                       if (handler) {
                           handler(success, object ? [object firstObject] : object, responseData, error);
                       }
                   }];
}

- (void)makePushNotificationsEnabled:(BOOL)enabled handler:(ObjectRequestCompletionHandler)handler {
    NSString *path = [NSString stringWithFormat:@"devices/%@", (enabled ? @"enable" : @"disable")];
    [self putObject:nil
               path:path
         parameters:nil
            handler:handler];
}

@end
