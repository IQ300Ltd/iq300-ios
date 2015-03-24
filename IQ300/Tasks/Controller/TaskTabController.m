//
//  TaskTabController.m
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TaskTabController.h"

#import "TInfoController.h"
#import "TCommentsController.h"
#import "TMembersController.h"
#import "TDocumentsController.h"
#import "THistoryController.h"
#import "IQService+Tasks.h"
#import "IQTask.h"
#import "TChangesCounter.h"
#import "IQNotificationCenter.h"

@interface TaskTabController () <IQTabBarControllerDelegate> {
    __weak id _notfObserver;
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
    [self updateCounters];
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

- (void)tabBarController:(IQTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    self.title = viewController.title;
}

- (void)updateControllerByTask:(IQTask*)task {
    if (task) {
        TInfoController * infoController = self.viewControllers[0];
        [infoController setTask:task];
        
        TCommentsController * commentsController = self.viewControllers[1];
        [commentsController setDiscussionId:task.discussionId];
        
        TMembersController * membersController = self.viewControllers[2];
        [membersController setTaskId:task.taskId];
        
        TDocumentsController * documentsController = self.viewControllers[3];
        documentsController.model.taskId = self.task.taskId;
        [documentsController setAttachments:[task.attachments array]];
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
                                                      infoController.tabBarItem.badgeValue = BadgTextFromInteger([counter.details integerValue]);
                                                      
                                                      TCommentsController * commentsController = self.viewControllers[1];
                                                      commentsController.tabBarItem.badgeValue = BadgTextFromInteger([counter.comments integerValue]);

                                                      TMembersController * membersController = self.viewControllers[2];
                                                      membersController.tabBarItem.badgeValue = BadgTextFromInteger([counter.users integerValue]);

                                                      TDocumentsController * documentsController = self.viewControllers[3];
                                                      documentsController.tabBarItem.badgeValue = BadgTextFromInteger(3);
                                                  }
                                              }];
}

#pragma mark - Notifications

- (void)applicationWillEnterForeground {
    [self updateCounters];
    [self updateTask];
}

- (void)resubscribeToIQNotifications {
    [self unsubscribeFromIQNotifications];
    
    __weak typeof(self) weakSelf = self;
    void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
        [weakSelf updateCounters];
        [weakSelf updateTask];
    };
    _notfObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQTasksDidChanged
                                                                       queue:nil
                                                                  usingBlock:block];
}

- (void)unsubscribeFromIQNotifications {
    if(_notfObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_notfObserver];
    }
}

@end
