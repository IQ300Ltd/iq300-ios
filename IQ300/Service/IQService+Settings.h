//
//  IQService+Settings.h
//  IQ300
//
//  Created by Viktor Shabanov on 03.04.17.
//  Copyright © 2017 Tayphoon. All rights reserved.
//

#import "IQService.h"

@interface IQService (Settings)

- (void)pushNotificationsSettingsWithHandler:(ObjectRequestCompletionHandler)handler;

- (void)makePushNotificationsEnabled:(BOOL)enabled handler:(ObjectRequestCompletionHandler)handler;

@end
