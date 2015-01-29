//
//  AppDelegate.m
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <RestKit/RestKit.h>
#import <MMDrawerController/MMDrawerController.h>

#import "AppDelegate.h"
#import "TasksController.h"
#import "MessagesController.h"
#import "MenuViewController.h"
#import "IQNavigationController.h"
#import "NotificationsContoller.h"
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

#define IPHONE_OS_VERSION_8 (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 0.0f : 7.0f)


@interface AppDelegate () {
    UIBackgroundTaskIdentifier _backgroundIdentifier;
}

@end

@implementation AppDelegate

+ (void)logout {
    AppDelegate * delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    LoginController * loginViewController = [[LoginController alloc] init];
    [delegate.window.rootViewController presentViewController:loginViewController animated:NO completion:nil];
    UITabBarController * center = ((UITabBarController*)delegate.drawerController.centerViewController);
    NSArray * controllers = [center viewControllers];
    [center setSelectedIndex:0];
    [controllers makeObjectsPerformSelector:@selector(popToRootViewControllerAnimated:) withObject:@(NO)];
    [[IQService sharedService] logout];
    [IQSession setDefaultSession:nil];
    [[IQNotificationCenter defaultCenter] resetAllObservers];
    [IQNotificationCenter setDefaultCenter:nil];
    [delegate.drawerController toggleDrawerSide:MMDrawerSideLeft animated:NO completion:nil];
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
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        return [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    }
    else {
        return ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] & UIRemoteNotificationTypeAlert);
    }
}

+ (void)registerForRemoteNotifications {
    if([IQSession defaultSession]) {
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            UIUserNotificationType types = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                                 settingsForTypes:types
                                                                                 categories:nil]];
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                                   UIRemoteNotificationTypeSound |
                                                                                   UIRemoteNotificationTypeAlert)];
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RKLogConfigureByName("RestKit/Support", RKLogLevelError);
    RKLogConfigureByName("RestKit/Network", RKLogLevelError);
    RKLogConfigureByName("RestKit/App", RKLogLevelError);
    
    NSLog(@"\n\nService adress is %@\n\n", SERVICE_URL);

    [IQService serviceWithURL:SERVICE_URL andSession:[IQSession defaultSession]];
    [AppDelegate setupNotificationCenter];
    [AppDelegate registerForRemoteNotifications];

    MenuViewController * leftDrawer = [[MenuViewController alloc] init];

    NotificationsContoller * notifications = [[NotificationsContoller alloc] init];
    IQNavigationController * notificationsNav = [[IQNavigationController alloc] initWithRootViewController:notifications];
    
    MessagesController * messages = [[MessagesController alloc] init];
    IQNavigationController * messagesNav = [[IQNavigationController alloc] initWithRootViewController:messages];
    
    UITabBarController * center = [[UITabBarController alloc] init];
    center.tabBar.layer.borderWidth = 0;
    
    [center setViewControllers:@[notificationsNav, messagesNav]];
    
    MMDrawerController * drawerController = [[IQDrawerController alloc]
                                             initWithCenterViewController:center
                                             leftDrawerViewController:leftDrawer];
    self.drawerController = drawerController;
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setMaximumLeftDrawerWidth:MENU_WIDTH];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModePanningDrawerView | MMCloseDrawerGestureModePanningCenterView];
    [self.drawerController setShowsShadow:YES];
    [self.drawerController setShouldStretchDrawer:NO];
    
    [self applyCustomizations];
    
    __weak typeof(self) weakSelf = self;
    [self.drawerController setGestureShouldRecognizeTouchBlock:^BOOL(MMDrawerController *drawerController, UIGestureRecognizer *gesture, UITouch *touch) {
        if (weakSelf.drawerController.openSide == MMDrawerSideNone &&
            [gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            
            UIView *centerView = drawerController.centerViewController.view;
            CGRect rect = UIEdgeInsetsInsetRect(centerView.frame, UIEdgeInsetsMake(0.0, 0.0, 0.0, centerView.frame.size.width * 0.60f));
            if (CGRectContainsPoint(rect, [touch locationInView:centerView])) {
                return YES;
            }
        }
        return NO;
    }];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.drawerController;
    
    [self.window makeKeyAndVisible];
    
    if(![IQSession defaultSession]) {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        LoginController * loginViewController = [[LoginController alloc] init];
        [self.window.rootViewController presentViewController:loginViewController animated:NO completion:nil];
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
#endif
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self updateGlobalCounters];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
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
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Recive notification %@", notfObject);
    
    NSDictionary * notificable = notfObject[@"notificable"];
    NSNumber * objectId = notificable[@"id"];
    NSString * objectType = notificable[@"type"];
    NSInteger messagesTab = 1;
    
    UITabBarController * tabController = ((UITabBarController*)self.drawerController.centerViewController);
    if([objectType isEqualToString:@"Conversation"]) {
        UINavigationController * navController = tabController.viewControllers[messagesTab];
        BOOL isDiscussionOpen = ([navController.topViewController isKindOfClass:[DiscussionController class]]);
        DiscussionController * controller = (isDiscussionOpen) ? (DiscussionController*)navController.topViewController : [[DiscussionController alloc] init];
        MessagesController * messagesController = navController.viewControllers[0];
        
        BOOL needReload = (isDiscussionOpen && ![controller.model.discussion.conversation.conversationId isEqualToNumber:objectId]);
        if(needReload) {
            [controller.model setSubscribedToNotifications:NO];
        }
        
        ObjectLoaderCompletionHandler handler = ^(BOOL success, IQConversation * conver, NSData *responseData, NSError *error) {
            if(success) {
                NSPredicate * companionsPredicate = [NSPredicate predicateWithFormat:@"userId != %@", [IQSession defaultSession].userId];
                NSArray * companions = [[conver.discussion.users filteredSetUsingPredicate:companionsPredicate] allObjects];
                IQUser * companion = [companions lastObject];
                
                DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:conver.discussion];
                model.companionId = companion.userId;
                
                controller.title = companion.displayName;
                controller.model = model;
                
                if(!isDiscussionOpen) {
                    controller.hidesBottomBarWhenPushed = YES;
                    [tabController setSelectedIndex:messagesTab];
                    [navController pushViewController:controller animated:NO];
                }
                else if(needReload) {
                    [controller.tableView reloadData];
                    [controller reloadDataWithCompletion:nil];
                }
                
                [MessagesModel markConversationAsRead:conver completion:^(NSError *error) {
                    [messagesController updateGlobalCounter];
                }];
            }
        };
        
        [[IQService sharedService] conversationWithId:objectId  handler:handler];
    }
    else if([objectType length] > 0) {
        [self updateGlobalCounters];
        [tabController setSelectedIndex:0];
    }
}

- (void)applyCustomizations {
    //set status bar black color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName : [UIColor whiteColor],
                                                           NSFontAttributeName : [UIFont fontWithName:IQ_HELVETICA size:15]
                                                           }];
    
    //custromize navigation bar background
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top_header_bg"]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    
    UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar_background.png"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
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
    UITabBarController * tabBarController = (UITabBarController*)self.drawerController.centerViewController;
    
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

@end
