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
#import "MenuViewController.h"
#import "IQNavigationController.h"
#import "NotificationsContoller.h"
#import "IQDrawerController.h"
#import "IQService.h"
#import "IQSession.h"
#import "LoginController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RKLogConfigureByName("RestKit/Support", RKLogLevelError);
    RKLogConfigureByName("RestKit/Network", RKLogLevelError);
    RKLogConfigureByName("RestKit/App", RKLogLevelError);

    MenuViewController * leftDrawer = [[MenuViewController alloc] init];

    NotificationsContoller * notifications = [[NotificationsContoller alloc] init];
    IQNavigationController * notificationsNav = [[IQNavigationController alloc] initWithRootViewController:notifications];
    
    TasksController * tasksViewContoller = [[TasksController alloc] init];
    IQNavigationController * tasksNav = [[IQNavigationController alloc] initWithRootViewController:tasksViewContoller];
    
    UIViewController * projects = [[UIViewController alloc] init];
    UIImage * barImage = [[UIImage imageNamed:@"projects_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * barImageSelected = [[UIImage imageNamed:@"projects_tab_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    projects.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImageSelected];
    projects.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    IQNavigationController * projectsNav = [[IQNavigationController alloc] initWithRootViewController:projects];

    UIViewController * calendar = [[UIViewController alloc] init];
    barImage = [[UIImage imageNamed:@"calendar_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    barImageSelected = [[UIImage imageNamed:@"calendar_tab_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    calendar.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImageSelected];
    calendar.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    IQNavigationController * calendarNav = [[IQNavigationController alloc] initWithRootViewController:calendar];

    UIViewController * more = [[UIViewController alloc] init];
    barImage = [[UIImage imageNamed:@"more_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    more.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:nil];
    more.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    IQNavigationController * moreNav = [[IQNavigationController alloc] initWithRootViewController:more];

    UITabBarController * center = [[UITabBarController alloc] init];
    center.tabBar.layer.borderWidth = 0;
    
    [center setViewControllers:@[notificationsNav, tasksNav, projectsNav, calendarNav, moreNav]];
    
    MMDrawerController * drawerController = [[IQDrawerController alloc]
                                             initWithCenterViewController:center
                                             leftDrawerViewController:leftDrawer];
    self.drawerController = drawerController;
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setMaximumLeftDrawerWidth:265.0];
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

    if (![IQSession defaultSession]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        LoginController * loginViewController = [[LoginController alloc] init];
        [self.window.rootViewController presentViewController:loginViewController animated:NO completion:nil];
    }
    else {
        [IQService serviceWithURL:SERVICE_URL andSession:[IQSession defaultSession]];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applyCustomizations {
    //set status bar black color
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //custromize navigation bar background
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top_header_bg"]
                                      forBarPosition:UIBarPositionAny
                                          barMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    
    UIImage* tabBarBackground = [UIImage imageNamed:@"tabbar_background.png"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tbar_sel_indicator.png"]];
}

@end
