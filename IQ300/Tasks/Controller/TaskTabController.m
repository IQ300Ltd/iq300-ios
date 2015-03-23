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
#import "IQTask.h"

@interface TaskTabController () <IQTabBarControllerDelegate>

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
        [membersController setTask:task];
        
        TDocumentsController * documentsController = self.viewControllers[3];
        documentsController.model.taskId = self.task.taskId;
        [documentsController setAttachments:[task.attachments array]];
    }
}

@end
