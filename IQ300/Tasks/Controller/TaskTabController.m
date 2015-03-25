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
#import "THistoryController.h"
#import "IQService+Tasks.h"
#import "IQTask.h"
#import "IQUser.h"
#import "TChangesCounter.h"
#import "IQNotificationCenter.h"
#import "IQSession.h"
#import "TaskTabItemController.h"
#import "TaskPolicyInspector.h"
#import "TaskNotifications.h"

@interface TaskTabController () <IQTabBarControllerDelegate> {
    __weak id _notfObserver;
    TaskPolicyInspector * _policyInspector;
}

@end

@implementation TaskTabController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = self;
        [self setViewControllers:@[[[TInfoController alloc] init],
                                   [[TCommentsController alloc] init],
                                   [[TMembersController alloc] init],
                                   [[TDocumentsController alloc] init],
                                   [[THistoryController alloc] init]
                                   ]];
        [self resubscribeToIQNotifications];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem * backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backWhiteArrow.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(backButtonAction:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    [self.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"task_tab_sel.png"]];
    
    [self updateControllerByTask:self.task];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tasksDidLeavedNotification)
                                                 name:IQTasksDidLeavedNotification
                                               object:nil];

    [self updateCounters];
    [self markTaskAsReadedIfNeed];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

- (BOOL)showMenuBarItem {
    return NO;
}

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IQTabBarController Delegate

- (void)tabBarController:(IQTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    self.title = viewController.title;
    
    if ([viewController conformsToProtocol:@protocol(TaskTabItemController)]) {
        id<TaskTabItemController> controller = (id<TaskTabItemController>)viewController;
        [self updateReadStatusForTabController:controller];
    }
}

#pragma mark - Private methods

- (void)updateReadStatusForTabController:(id<TaskTabItemController>)controller {
    if (controller && [controller.badgeValue integerValue] > 0) {
        [[IQService sharedService] markCategoryAsReaded:controller.category
                                                 taskId:self.task.taskId
                                                handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                    if (success) {
                                                        controller.badgeValue = @(0);
                                                    }
                                                }];
    }
}

- (void)updateControllerByTask:(IQTask*)task {
    if (task) {
        TInfoController * infoController = self.viewControllers[0];
        [infoController setTask:task];
        [infoController setPolicyInspector:_policyInspector];
        
        TCommentsController * commentsController = self.viewControllers[1];
        [commentsController setDiscussionId:task.discussionId];
        [commentsController setPolicyInspector:_policyInspector];
        
        TMembersController * membersController = self.viewControllers[2];
        [membersController setTaskId:task.taskId];
        [membersController setPolicyInspector:_policyInspector];
        
        TDocumentsController * documentsController = self.viewControllers[3];
        documentsController.model.taskId = self.task.taskId;
        [documentsController setAttachments:[task.attachments array]];
        [documentsController setPolicyInspector:_policyInspector];
    }
}

- (void)updateTask {
    [[IQService sharedService] taskWithId:self.task.taskId
                                  handler:^(BOOL success, IQTask * task, NSData *responseData, NSError *error) {
                                      if (success) {
                                          self.task = task;
                                          [self updateControllerByTask:task];
                                      }
                                  }];
}

- (void)updateCounters {
    [[IQService sharedService] taskChangesCounterById:self.task.taskId
                                              handler:^(BOOL success, TChangesCounter * counter, NSData *responseData, NSError *error) {
                                                  if (success && counter) {
                                                      TInfoController * infoController = self.viewControllers[0];
                                                      infoController.badgeValue = counter.details;
                                                      
                                                      TCommentsController * commentsController = self.viewControllers[1];
                                                      commentsController.badgeValue = counter.comments;

                                                      TMembersController * membersController = self.viewControllers[2];
                                                      membersController.badgeValue = counter.users;

                                                      TDocumentsController * documentsController = self.viewControllers[3];
                                                      documentsController.badgeValue = counter.documents;
                                                      
                                                      if (self.selectedIndex != NSNotFound &&
                                                          [self.viewControllers[self.selectedIndex] conformsToProtocol:@protocol(TaskTabItemController)]) {
                                                          [self updateReadStatusForTabController:self.viewControllers[self.selectedIndex]];
                                                      }
                                                  }
                                              }];
}

- (void)markTaskAsReadedIfNeed {
    if ([self.task.status isEqualToString:@"new"] &&
        [self.task.executor.userId isEqualToNumber:[IQSession defaultSession].userId]) {
        [[IQService sharedService] changeStatus:@"browse"
                                  forTaskWithId:self.task.taskId
                                         reason:nil
                                        handler:^(BOOL success, IQTask * task, NSData *responseData, NSError *error) {
                                            if(success) {
                                                self.task = task;
                                                [self updateControllerByTask:task];
                                            }
                                        }];
    }
}

#pragma mark - Notifications

- (void)applicationWillEnterForeground {
    [self updateCounters];
    [self updateTask];
}

- (void)tasksDidLeavedNotification {
    [self.navigationController popViewControllerAnimated:YES];
    
    NSNumber * taskId = self.task.taskId;
    
    [self.task.managedObjectContext deleteObject:self.task];
    
    NSError *saveError = nil;
    if(![[IQService sharedService].context saveToPersistentStore:&saveError] ) {
        NSLog(@"Failed to delete task by id %@ with error: %@", taskId, saveError);
    }
}

- (void)resubscribeToIQNotifications {
    [self unsubscribeFromIQNotifications];
    
    __weak typeof(self) weakSelf = self;
    void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
        NSArray * taskIds = notf.userInfo[IQNotificationDataKey][@"object_ids"];

        if([taskIds containsObject:weakSelf.task.taskId]) {
            [weakSelf updateCounters];
            [weakSelf updateTask];
        }
    };
    _notfObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQTasksDidChangedNotification
                                                                       queue:nil
                                                                  usingBlock:block];
}

- (void)unsubscribeFromIQNotifications {
    if(_notfObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_notfObserver];
    }
}

- (void)dealloc {
    [self unsubscribeFromIQNotifications];
}

@end
