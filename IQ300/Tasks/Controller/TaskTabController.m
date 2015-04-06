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

@interface TaskTabController () <IQTabBarControllerDelegate> {
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
                                   [[TaskActivitiesController alloc] init]
                                   ]];
    }
    return self;
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
    
    [self.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"task_tab_sel.png"]];
    
    [self updateControllerByTask:self.task];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tasksDidLeavedNotification)
                                                 name:IQTasksDidLeavedNotification
                                               object:nil];

    [self updateCounters];
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
    if (task) {
        TInfoController * infoController = self.viewControllers[0];
        [infoController setTask:task];
        [infoController setPolicyInspector:_policyInspector];
        
        TCommentsController * commentsController = self.viewControllers[1];
        [commentsController setTaskId:task.taskId];
        [commentsController setDiscussionId:task.discussionId];
        [commentsController setPolicyInspector:_policyInspector];
        
        TMembersController * membersController = self.viewControllers[2];
        [membersController setTaskId:task.taskId];
        [membersController setPolicyInspector:_policyInspector];
        
        TDocumentsController * documentsController = self.viewControllers[3];
        [documentsController setTaskId:task.taskId];
        [documentsController setPolicyInspector:_policyInspector];
        
        TaskActivitiesController * activitiesController = self.viewControllers[4];
        [activitiesController setTaskId:task.taskId];
        [activitiesController setPolicyInspector:_policyInspector];
    }
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

@end
