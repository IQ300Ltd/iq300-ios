//
//  AppDelegate.m
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>
#import <MMDrawerController/MMDrawerController.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <SDWebImage/SDWebImageManager.h>

#import "AppDelegate.h"
#import "TasksController.h"
#import "MessagesController.h"
#import "MenuViewController.h"
#import "IQNavigationController.h"
#import "NotificationsController.h"
#import "IQDrawerController.h"
#import "IQService+Messages.h"
#import "IQSession.h"
#import "LoginController.h"
#import "MenuConsts.h"
#import "IQNotificationCenter.h"
#import "IQUser.h"
#import "DiscussionController.h"
#import "IQConversation.h"
#import "DiscussionModel.h"
#import "IQDiscussion.h"
#import "DispatchAfterExecution.h"
#import "DeviceToken.h"
#import "RegistrationStatusController.h"

#ifdef IPAD
#import "LeftSideTabBarController.h"
#import "FeedbacksController.h"
#endif

@interface AppDelegate () {
    UIBackgroundTaskIdentifier _backgroundIdentifier;
}

@end

@implementation AppDelegate

+ (void)continueLoginProccessWithCompletion:(void (^)(NSError * error))completion {
    [[IQService sharedService] userInfoWithHandler:^(BOOL success, IQUser * user, NSData *responseData, NSError *error) {
        if(success) {
            [IQSession setDefaultSession:[IQService sharedService].session];
            [AppDelegate setupNotificationCenter];
            [AppDelegate registerForRemoteNotifications];
            [GAIService sendEventForCategory:GAICommonEventCategory
                                      action:@"event_action_common_login"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:AccountDidChangedNotification
                                                                object:nil];
            if (completion) {
                completion(nil);
            }
        }
    }];
}

+ (void)logout {
    AppDelegate * delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    LoginController * loginViewController = [[LoginController alloc] init];
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    [navigationController setNavigationBarHidden:YES];
    [delegate.window.rootViewController presentViewController:navigationController animated:NO completion:nil];
   
    [[IQService sharedService] logout];
    [IQSession setDefaultSession:nil];
    [[IQNotificationCenter defaultCenter] resetAllObservers];
    [IQNotificationCenter setDefaultCenter:nil];

    UITabBarController * center = ((UITabBarController*)delegate.drawerController.centerViewController);
    
    for (UINavigationController * controller in center.viewControllers) {
        [controller popToRootViewControllerAnimated:NO];
    }
    
    [center setSelectedIndex:0];
    if (delegate.drawerController.openSide == MMDrawerSideLeft) {
        [delegate.drawerController toggleDrawerSide:MMDrawerSideLeft animated:NO completion:nil];
    }
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}

+ (void)setupNotificationCenter {
    if([IQSession defaultSession]) {
        IQUser * user = [IQUser userWithId:[IQSession defaultSession].userId
                                 inContext:[IQService sharedService].context];
        if(user) {
            NSString * token = [NSString stringWithFormat:@"%@ %@", [IQSession defaultSession].tokenType, [IQSession defaultSession].token];
            [IQNotificationCenter centerWithKey:PUSHER_APP_KEY token:token channelName:user.pusherChannel];
        }
    }
}

+ (BOOL)pushNotificationsEnabled {
    return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
}

+ (void)registerForRemoteNotifications {
#if !(TARGET_IPHONE_SIMULATOR)
    if([IQSession defaultSession]) {
        UIUserNotificationType types = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:types
                                                                             categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
#endif
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RKLogConfigureByName("RestKit/Support", RKLogLevelError);
    RKLogConfigureByName("RestKit/Network", RKLogLevelError);
    RKLogConfigureByName("RestKit/App", RKLogLevelError);
    
    NSLog(@"\n\nService adress is %@\n\n", SERVICE_URL);
    
    [IQService serviceWithURL:[NSString stringWithFormat:@"%@%@", SERVER_URL, @"/api/v2"] andSession:[IQSession defaultSession]];
    [AppDelegate setupNotificationCenter];
    [AppDelegate registerForRemoteNotifications];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    MenuViewController * leftDrawer = [[MenuViewController alloc] init];

    Class navigationControllerClass = [IQNavigationController class];
    NotificationsController * notifications = [[NotificationsController alloc] init];
    UINavigationController * notificationsNav = [[navigationControllerClass alloc] initWithRootViewController:notifications];
    
    TasksController * tasks = [[TasksController alloc] init];
    UINavigationController * tasksNav = [[navigationControllerClass alloc] initWithRootViewController:tasks];
   
    MessagesController * messages = [[MessagesController alloc] init];
    UINavigationController * messagesNav = [[navigationControllerClass alloc] initWithRootViewController:messages];
    
#ifdef IPAD
    Class tabBarClass = [LeftSideTabBarController class];
#else
    Class tabBarClass = [UITabBarController class];
#endif
   
    UITabBarController * center = [[tabBarClass alloc] init];
    
#ifdef IPAD
    FeedbacksController * feedbacksController = [[FeedbacksController alloc] init];
    UINavigationController * feedbacksNav = [[navigationControllerClass alloc] initWithRootViewController:feedbacksController];
    [center setViewControllers:@[notificationsNav, tasksNav, messagesNav, feedbacksNav]];
#else
    center.tabBar.layer.borderWidth = 0;
    [center setViewControllers:@[notificationsNav, tasksNav, messagesNav]];
#endif
    
#ifndef IPAD
    center.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar_background.png"];
    MMDrawerController * drawerController = [[IQDrawerController alloc]
                                             initWithCenterViewController:center
                                             leftDrawerViewController:leftDrawer];
    self.drawerController = drawerController;
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeCustom];
    [self.drawerController setMaximumLeftDrawerWidth:MENU_WIDTH];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningDrawerView |
     MMCloseDrawerGestureModePanningCenterView];
    [self.drawerController setShowsShadow:YES];
    [self.drawerController setShouldStretchDrawer:NO];
    
    __weak typeof(self) weakSelf = self;
    [self.drawerController setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch) {
        if (weakSelf.drawerController.openSide == MMDrawerSideNone &&
            [gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            
            UIView * centerView = drawerController.centerViewController.view;
            CGRect rect = UIEdgeInsetsInsetRect(centerView.frame, UIEdgeInsetsMake(0.0, 0.0, 0.0, centerView.frame.size.width * 0.80f));
            if (CGRectContainsPoint(rect, [touch locationInView:centerView])) {
                return YES;
            }
        }
        return NO;
    }];
    self.window.rootViewController = self.drawerController;
#else
    LeftSideTabBarController * tabController = (LeftSideTabBarController*)center;
    tabController.menuController = leftDrawer;
    tabController.menuControllerHidden = NO;
    tabController.menuControllerWidth = 224.0f;
    tabController.tabBar.selectionIndicatorImage = [UIImage imageNamed:@"tabbar_selected_image.png"];
    tabController.tabBar.backgroundImage = [UIImage imageNamed:@"left_tabbar_background.png"];
    self.window.rootViewController = tabController;
#endif
    
    [self applyCustomizations];

    [self.window makeKeyAndVisible];
    
    if(![IQSession defaultSession]) {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        LoginController * loginViewController = [[LoginController alloc] init];
        UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [navigationController setNavigationBarHidden:YES];
        [self.window.rootViewController presentViewController:navigationController animated:NO completion:nil];
    }
    else {
        [self updateGlobalCounters];
    }
    
    if (launchOptions != nil) {
        NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSLog(@"Launch by remoute notification %@", dictionary);
        if (dictionary != nil && [IQSession defaultSession]) {
            [self showControllerForNotification:dictionary];
        }
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

#ifdef DEBUG
    [self instalCrashSignalCatchers];
#else
    [Fabric with:@[CrashlyticsKit]];
#endif
    
    [GAIService initializeGoogleAnalytics];
    
    [[SDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url) {
        url = [[NSURL alloc] initWithScheme:url.scheme host:url.host path:url.path];
        return [url absoluteString];
    }];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if ([IQSession defaultSession]) {
        [self updateGlobalCounters];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([IQSession defaultSession]) {
        [IQService sharedService].session = nil;
        [AppDelegate logout];
    }
    
    NSMutableParagraphStyle * paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSMutableDictionary * attributes = @{
                                         NSForegroundColorAttributeName : [UIColor colorWithHexInt:0x272727],
                                         NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:18],
                                         NSParagraphStyleAttributeName  : paragraphStyle
                                         }.mutableCopy;
    NSString * title = [NSString stringWithFormat:@"%@\n\n", NSLocalizedString(@"Thank you for registering!", nil)];
    NSMutableAttributedString * statusMessage = [[NSMutableAttributedString alloc] initWithString:title
                                                                                       attributes:attributes];
    
    [attributes setValue:[UIFont fontWithName:IQ_HELVETICA size:15]
                  forKey:NSFontAttributeName];

    [statusMessage appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Account activation", nil)
                                                                          attributes:attributes]];
    
    UINavigationController * navController = ((UINavigationController*)self.window.rootViewController.presentedViewController);
    RegistrationStatusController * controller = [[RegistrationStatusController alloc] init];
    controller.statusMessage = statusMessage;
    [navController pushViewController:controller animated:NO];
    
    RequestCompletionHandler handler = ^(BOOL success, NSData *responseData, NSError *error) {
        if(success) {
            [self continueLoginProccess];
        }
        else if (error) {
            NSDictionary * attributes = @{
                                          NSForegroundColorAttributeName : [UIColor colorWithHexInt:0x272727],
                                          NSFontAttributeName            : [UIFont fontWithName:IQ_HELVETICA size:18]
                                          }.mutableCopy;
            
            NSMutableAttributedString * statusMessage = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Thank you for registering!", nil)
                                                                                               attributes:attributes];
            NSString * errorDescription = nil;
            if (IsNetworUnreachableError(error) || ![IQService sharedService].isServiceReachable) {
                errorDescription = NSLocalizedString(INTERNET_UNREACHABLE_MESSAGE, nil);
            }
            else {
                errorDescription = error.localizedDescription;
            }
            
            [attributes setValue:[UIFont fontWithName:IQ_HELVETICA size:15]
                          forKey:NSFontAttributeName];
            [attributes setValue:[UIColor colorWithHexInt:0xca301e]
                          forKey:NSForegroundColorAttributeName];

            [statusMessage appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", errorDescription]
                                                                                  attributes:attributes]];
            controller.statusMessage = statusMessage;
        }
    };

    [[IQService sharedService] confirmRegistrationWithToken:[url lastPathComponent]
                                                deviceToken:[DeviceToken uniqueIdentifier]
                                                    handler:handler];
    return YES;
}

- (void)continueLoginProccess {
    [[IQService sharedService] userInfoWithHandler:^(BOOL success, IQUser * user, NSData *responseData, NSError *error) {
        if(success) {
            [IQSession setDefaultSession:[IQService sharedService].session];
            [AppDelegate setupNotificationCenter];
            [AppDelegate registerForRemoteNotifications];
            [GAIService sendEventForCategory:GAICommonEventCategory
                                      action:@"event_action_common_login"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:AccountDidChangedNotification
                                                                object:nil];
            
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }
    }];
}
#pragma mark - Notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
    if ([IQSession defaultSession]) {
        NSString* newToken = [deviceToken description];
        newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];

        NSLog(@"Device token is: %@", newToken);

        [[IQService sharedService] registerDeviceForRemoteNotificationsWithToken:newToken
                                                                         handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                                             if(!success) {
                                                                                 NSLog(@"Failed registry device on server with error:%@", error);
                                                                             }
                                                                         }];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
    if (application.applicationState == UIApplicationStateInactive ||
        application.applicationState == UIApplicationStateBackground) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        NSLog(@"Recive remote notification %@", userInfo);
        [self showControllerForNotification:userInfo];
    }
}

#pragma mark - Private methods

- (void)showControllerForNotification:(NSDictionary*)notfObject {
    NSDictionary * notificable = notfObject[@"notificable"];
    NSNumber * objectId = notificable[@"id"];
    NSString * objectType = notificable[@"type"];
    NSInteger messagesTab = 2;
    
    UITabBarController * tabController = ((UITabBarController*)self.drawerController.centerViewController);
    UINavigationController * navController = tabController.viewControllers[messagesTab];
    BOOL isDiscussionOpen = (tabController.selectedIndex == messagesTab && [navController.topViewController isKindOfClass:[DiscussionController class]]);
    NSNumber * conversationId = (isDiscussionOpen) ? ((DiscussionController*)navController.topViewController).model.discussion.conversation.conversationId : nil;

    if([[objectType lowercaseString] isEqualToString:@"conversation"]) {
        if((isDiscussionOpen && ![conversationId isEqualToNumber:objectId]) || !isDiscussionOpen) {
            MessagesController * messagesController = navController.viewControllers[0];
            
            ObjectRequestCompletionHandler handler = ^(BOOL success, IQConversation * conversation, NSData *responseData, NSError *error) {
                if(success) {
                    DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:conversation.discussion];
                    DiscussionController * controller = [[DiscussionController alloc] init];
                    controller.hidesBottomBarWhenPushed = YES;
                    controller.title = conversation.title;
                    controller.model = model;
                    
                    if(!isDiscussionOpen) {
                        [tabController setSelectedIndex:messagesTab];
                        [navController pushViewController:controller animated:NO];
                    }
                    else  {
                        NSArray * newStack = @[navController.viewControllers[0], controller];
                        [navController setViewControllers:newStack animated:YES];
                    }
                    
                    [MessagesModel markConversationAsRead:conversation completion:^(NSError *error) {
                        [messagesController updateGlobalCounter];
                    }];
                }
            };
            
            [[IQService sharedService] conversationWithId:objectId  handler:handler];
        }
    }
    else if([objectType length] > 0) {
        [self updateGlobalCounters];
        [tabController setSelectedIndex:0];
    }
    
    [GAIService sendEventForCategory:GAICommonEventCategory
                              action:@"event_action_common_push_transition"];
}

- (void)applyCustomizations {
    //[self debugAllNotification];
    
    //set status bar black color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    CGFloat fontSize = (IS_IPAD) ? 17.0f : 15.0f;
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName : [UIColor whiteColor],
                                                           NSFontAttributeName : [UIFont fontWithName:IQ_HELVETICA size:fontSize]
                                                           }];
    
    //custromize navigation bar background
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top_header_bg"]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSForegroundColorAttributeName : [UIColor colorWithHexInt:0xc1c1c1],
                                                        NSFontAttributeName : [UIFont fontWithName:IQ_HELVETICA size:10]
                                                       }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSForegroundColorAttributeName : [UIColor colorWithHexInt:0xf1f5f6],
                                                        NSFontAttributeName : [UIFont fontWithName:IQ_HELVETICA size:10]
                                                       }
                                             forState:UIControlStateSelected];
}

- (void)updateGlobalCounters {
    UITabBarController * tabBarController =  (IS_IPAD) ? (UITabBarController*)self.window.rootViewController :
                                                         (UITabBarController*)self.drawerController.centerViewController;
    
    for (UINavigationController * navController in tabBarController.viewControllers) {
        UIViewController * controller = [navController.viewControllers objectAtIndex:0];
        if([controller respondsToSelector:@selector(updateGlobalCounter)]) {
            [controller performSelector:@selector(updateGlobalCounter)];
        }
    }
}

- (void)beginBackgroundTaskWithBlock:(void(^)(void))backgroundBlock  {
    if(backgroundBlock) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            _backgroundIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [self endBackgroundTask];
            }];
            backgroundBlock();
        });
    }
}

- (void)endBackgroundTask {
    [[UIApplication sharedApplication] endBackgroundTask:_backgroundIdentifier];
    _backgroundIdentifier = UIBackgroundTaskInvalid;
}

#ifdef DEBUG

/*
 Custom uncaught exception catcher
 */
void UncaughtExceptionHandler(NSException *exception) {
    NSString * crashReport = [NSString stringWithFormat:@"\n\n*** Terminating app due to uncaught exception '%@', reason:\n'%@'\n\n*** First throw call stack:\n%@\n\n", [exception class],
                              exception,
                              [exception callStackSymbols]];
    NSLog(@"%@", crashReport);
}

/*
 Custom signal catcher
 */
void SignalHandler(int sig) {
    NSLog(@"Application resive a signal %i", sig);
}

- (void)instalCrashSignalCatchers {
    // installs HandleExceptions as the Uncaught Exception Handler
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    // create the signal action structure
    struct sigaction appSignalAction;
    // initialize the signal action structure
    memset(&appSignalAction, 0, sizeof(appSignalAction));
    // set SignalHandler as the handler in the signal action structure
    appSignalAction.sa_handler = &SignalHandler;
    // set SignalHandler as the handlers for SIGABRT, SIGILL and SIGBUS
    sigaction(SIGABRT, &appSignalAction, NULL);
    sigaction(SIGILL, &appSignalAction, NULL);
    sigaction(SIGBUS, &appSignalAction, NULL);
    sigaction(SIGKILL, &appSignalAction, NULL);
}

#endif

- (void)debugAllNotification {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(),
                                    NULL,
                                    NotificationCenterCallBack,
                                    NULL,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
}

void NotificationCenterCallBack (CFNotificationCenterRef center,
                                 void *observer,
                                 CFStringRef name,
                                 const void *object,
                                 CFDictionaryRef userInfo)
{
    NSLog(@"name: %@", name);
    NSLog(@"userinfo: %@", userInfo);
}

@end
