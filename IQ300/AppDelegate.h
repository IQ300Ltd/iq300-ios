//
//  AppDelegate.h
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMDrawerController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) MMDrawerController *drawerController;

+ (void)continueLoginProccessWithCompletion:(void (^)(NSError * error))completion;
+ (void)logout;
+ (void)setupNotificationCenter;
+ (void)registerForRemoteNotifications;

+ (BOOL)pushNotificationsEnabled;

@end

