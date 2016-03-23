//
//  TSubtasksController.m
//  IQ300
//
//  Created by Vladislav Grigoriev on 22/03/16.
//  Copyright © 2016 Tayphoon. All rights reserved.
//

#import "TSubtasksController.h"
#import "TaskSubtasksModel.h"

#import "IQBadgeIndicatorView.h"
#import "UITabBarItem+CustomBadgeView.h"

#import "TSubtaskCell.h"

#import "IQService.h"
#import "IQService+Tasks.h"

#import "DispatchAfterExecution.h"

#import "UIScrollView+PullToRefreshInsert.h"
#import "TaskPolicyInspector.h"

#import "TaskTabController.h"
#import "IQSubtask.h"
#import "IQTask.h"

#import "TaskModel.h"
#import "TaskController.h"

@interface TSubtasksController ()

@property (nonatomic, assign) BOOL resetReadFlagAutomatically;

@end

@implementation TSubtasksController

@synthesize model;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Subtasks", nil);
        
        UIImage * barImage = [[UIImage imageNamed:@"task_history_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        float imageOffset = 6;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImage];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        
        IQBadgeIndicatorView * badgeView = [[IQBadgeIndicatorView alloc] init];
        badgeView.badgeColor = [UIColor colorWithHexInt:0xe74545];
        badgeView.strokeBadgeColor = [UIColor whiteColor];
        badgeView.frame = CGRectMake(0, 0, 9.0f, 9.0f);
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(6.5f, 10.5f);
        
        self.model = [[TaskSubtasksModel alloc] init];;
    }
    return self;
}

- (void)setBadgeValue:(NSNumber *)badgeValue {
    if(!self.resetReadFlagAutomatically) {
        self.tabBarItem.badgeValue = BadgTextFromInteger([badgeValue integerValue]);
    }
}

- (NSNumber*)badgeValue {
    return @([self.tabBarItem.badgeValue integerValue]);
}

- (void)setTask:(IQTask *)task {
    _task = task;
    self.model.taskId = task.taskId;
}

- (void)setPolicyInspector:(TaskPolicyInspector *)policyInspector {
    _policyInspector = policyInspector;
    [self updateInterfaceFoPolicies];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    __weak typeof(self) weakSelf = self;
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf.model updateModelWithCompletion:^(NSError *error) {
             [self proccessServiceError:error];
             [self.tableView reloadData];
             [self updateNoDataLabelVisibility];
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionTop];
    
    [self.tableView insertPullToRefreshWithActionHandler:^{
        [weakSelf.model loadNextPartWithCompletion:^(NSError *error) {
            [self proccessServiceError:error];
            [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionBottom] stopAnimating];

        }];
    } position:SVPullToRefreshPositionBottom];
    
    self.tableView.tableFooterView = [UIView new];
    [self.noDataLabel setText:NSLocalizedString(@"No subtasks", nil)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.noDataLabel.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [self updateInterfaceFoPolicies];
    self.resetReadFlagAutomatically = YES;
    [self resetReadFlag];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateModel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.resetReadFlagAutomatically = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.model numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.model numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSubtaskCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQSubtask *item = [self.model itemAtIndexPath:indexPath];
    cell.item = item;
    
    
//    cell.enabled = _changeStateEnabled;
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQSubtask * subtask = [self.model itemAtIndexPath:indexPath];
    
    if ([subtask.subtaskId isEqual:_priveousTaskId]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [[IQService sharedService] taskWithId:subtask.subtaskId handler:^(BOOL success, IQTask *task, NSData *responseData, NSError *error) {
            if (success) {
                TaskPolicyInspector * policyInspector = [[TaskPolicyInspector alloc] initWithTaskId:task.taskId];
                TaskTabController * controller = [[TaskTabController alloc] init];
                controller.task = task;
                controller.policyInspector = policyInspector;
                controller.hidesBottomBarWhenPushed = YES;
                controller.priveousTaskId = _task.taskId;
                
                [self.navigationController pushViewController:controller animated:YES];
            }
            else {
                [self proccessServiceError:error];
            }
        }];

    }
}

#pragma mark - Private Methods

- (void)updateModel {
    if([IQSession defaultSession]) {
        [self showActivityIndicatorAnimated:YES completion:nil];
        
        [self.model updateModelWithCompletion:^(NSError *error) {
            if(!error) {
                [self.tableView reloadData];
            }
            
            [self updateNoDataLabelVisibility];
            dispatch_after_delay(0.5f, dispatch_get_main_queue(), ^{
                [self hideActivityIndicatorAnimated:YES completion:nil];
            });
        }];
    }
}

- (void)applicationWillEnterForeground {
    if (self.resetReadFlagAutomatically) {
        [self resetReadFlag];
    }
}

- (void)resetReadFlag {
    if (self.task.taskId) {
        [[IQService sharedService] markCategoryAsReaded:[self.model category]
                                                 taskId:_task.taskId
                                                handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                    if (success) {
                                                        self.tabBarItem.badgeValue = BadgTextFromInteger(0);
                                                    }
                                                }];
    }
}

- (void)updateInterfaceFoPolicies {
    if([self.policyInspector isActionAvailable:@"add_subtask" inCategory:@"details"]) {
        UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"white_add_ico.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(addButtonAction:)];
        self.parentViewController.navigationItem.rightBarButtonItem = addButton;
    }
    else {
        self.parentViewController.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)addButtonAction:(id)sender {
    TaskModel * taskModel = [[TaskModel alloc] initWithDefaultCommunity:_task.community parentTask:_task];
    
    
    TaskController * controller = [[TaskController alloc] init];
    controller.model = taskModel;
    controller.hidesBottomBarWhenPushed = YES;

    [self.navigationController pushViewController:controller
                                         animated:YES];

}




@end
