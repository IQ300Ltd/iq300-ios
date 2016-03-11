//
//  TaskTabController.m
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <RestKit/CoreData/NSManagedObjectContext+RKAdditions.h>

#import "TaskTabController.h"

#import "TInfoController.h"
#import "TCommentsController.h"
#import "TMembersController.h"
#import "TDocumentsController.h"
#import "TaskActivitiesController.h"
#import "IQService+Tasks.h"
#import "TChangesCounter.h"
#import "IQNotificationCenter.h"
#import "IQSession.h"
#import "TaskTabItemController.h"
#import "TaskPolicyInspector.h"
#import "TaskNotifications.h"
#import "IQTask.h"
#import "NSManagedObject+ActiveRecord.h"

@interface TaskTabController () <IQTabBarControllerDelegate> {
    CGFloat _tabbarWidth;
}

@end

@implementation TaskTabController

+ (void)taskTabControllerForTaskWithId:(NSNumber*)taskId completion:(void (^)(TaskTabController * controller, NSError * error))completion {
    [[IQService sharedService] taskWithId:taskId handler:^(BOOL success, IQTask * task, NSData *responseData, NSError *error) {
        if (error.code == kCFURLErrorNotConnectedToInternet && !task) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"discussionId == %@", taskId];
            task = [IQTask objectWithPredicate:predicate
                                     inContext:[IQService sharedService].context];
        }
        
        if (task) {
            TaskPolicyInspector * policyInspector = [[TaskPolicyInspector alloc] initWithTaskId:task.taskId];
            TaskTabController * controller = [[TaskTabController alloc] init];
            controller.task = task;
            controller.policyInspector = policyInspector;
            
            [policyInspector requestUserPoliciesWithCompletion:^(NSError *error) {
                if (completion) {
                    completion(controller, error);
                }
            }];
        }
        else if (completion) {
            completion(nil, error);
        }
    }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = self;
        [self setViewControllers:@[[[TInfoController alloc] init],
                                   [[TCommentsController alloc] init],
                                   [[TMembersController alloc] init],
                                   [[TDocumentsController alloc] init]
                                   ]];
    }
    return self;
}

- (void)setTask:(IQTask *)task {
    _task = task;
    [self updateControllerByTask:_task];
}

- (void)setPolicyInspector:(TaskPolicyInspector *)policyInspector {
    _policyInspector = policyInspector;
    [self updateControllersInspector:_policyInspector];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.separatorHeight = 0.5f;
    self.separatorColor = [UIColor colorWithHexInt:0xcccccc];
    self.separatorHidden = NO;
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    self.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar_background.png"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tasksDidLeavedNotification)
                                                 name:IQTasksDidLeavedNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [self updateCounters];
    [_policyInspector requestUserPoliciesWithCompletion:^(NSError *error) {
        if (!error) {
            [self updateControllersInspector:_policyInspector];
        }
        else {
            NSLog(@"Failed request policies for taskId %@ with error:%@", _task.taskId, error);
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
        
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (_tabbarWidth != self.tabBar.frame.size.width) {
        _tabbarWidth = self.tabBar.frame.size.width;
        CGSize tabItemSize = CGSizeMake(_tabbarWidth / (float)[self.viewControllers count], self.tabBar.frame.size.height);
        self.tabBar.selectionIndicatorImage = [UIImage imageWithColor:[UIColor colorWithHexInt:0x348dad]
                                                                 size:tabItemSize];
    }
}

- (BOOL)isLeftMenuEnabled {
    return NO;
}

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IQTabBarController Delegate

- (void)tabBarController:(IQTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    self.title = viewController.title;
}

#pragma mark - Private methods

- (void)updateControllerByTask:(IQTask*)task {
    TInfoController * infoController = self.viewControllers[0];
    [infoController setTask:task];
    
    TCommentsController * commentsController = self.viewControllers[1];
    [commentsController setTaskTitle:task.title];
    [commentsController setTaskId:task.taskId];
    [commentsController setDiscussionId:task.discussionId];
    
    TMembersController * membersController = self.viewControllers[2];
    [membersController setTaskId:task.taskId];
    
    TDocumentsController * documentsController = self.viewControllers[3];
    [documentsController setTaskId:task.taskId];
}

- (void)updateControllersInspector:(TaskPolicyInspector*)inspector {
    TInfoController * infoController = self.viewControllers[0];
    [infoController setPolicyInspector:inspector];
    
    TCommentsController * commentsController = self.viewControllers[1];
    [commentsController setPolicyInspector:inspector];
    
    TMembersController * membersController = self.viewControllers[2];
    [membersController setPolicyInspector:inspector];
    
    TDocumentsController * documentsController = self.viewControllers[3];
    [documentsController setPolicyInspector:inspector];
}

- (void)updateCounters {
    [[IQService sharedService] taskChangesCounterById:self.task.taskId
                                              handler:^(BOOL success, TChangesCounter * counter, NSData *responseData, NSError *error) {
                                                  if (success && counter) {
                                                      TInfoController * infoController = self.viewControllers[0];
                                                      if (self.selectedIndex != 0) {
                                                          infoController.badgeValue = counter.details;
                                                      }
                                                      
                                                      TCommentsController * commentsController = self.viewControllers[1];
                                                      if (self.selectedIndex != 1) {
                                                          commentsController.badgeValue = counter.comments;
                                                      }

                                                      TMembersController * membersController = self.viewControllers[2];
                                                      if (self.selectedIndex != 2) {
                                                          membersController.badgeValue = counter.users;
                                                      }

                                                      TDocumentsController * documentsController = self.viewControllers[3];
                                                      if (self.selectedIndex != 3) {
                                                          documentsController.badgeValue = counter.documents;
                                                      }
                                                  }
                                              }];
}

#pragma mark - Notifications

- (void)tasksDidLeavedNotification {
    [self.navigationController popViewControllerAnimated:YES];
    
    NSNumber * taskId = self.task.taskId;
    
    [self.task.managedObjectContext deleteObject:self.task];
    
    NSError *saveError = nil;
    if(![[IQService sharedService].context saveToPersistentStore:&saveError] ) {
        NSLog(@"Failed to delete task by id %@ with error: %@", taskId, saveError);
    }
}

- (void)applicationWillEnterForeground {
    [self updateCounters];
}

@end
