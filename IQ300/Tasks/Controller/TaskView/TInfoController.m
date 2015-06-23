//
//  TaskController.m
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//

#import "TInfoController.h"
#import "TInfoHeaderView.h"
#import "TodoListSectionView.h"
#import "IQTask.h"
#import "TodoListItemCell.h"
#import "IQBadgeIndicatorView.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "IQService+Tasks.h"
#import "TaskPolicyInspector.h"
#import "IQNotificationCenter.h"
#import "TChangesCounter.h"
#import "IQTask.h"
#import "IQUser.h"
#import "TTodoItemsController.h"
#import "TodoListModel.h"
#import "TaskController.h"
#import "IQTaskDataHolder.h"

@interface TInfoController() <TInfoHeaderViewDelegate, UIActionSheetDelegate> {
    __weak UIButton * _deferredActionButton;
    __weak id _notfObserver;
    BOOL _changeStateEnabled;
    BOOL _descriptionExpanded;
}

@property (nonatomic, assign) BOOL resetReadFlagAutomatically;

@end

@implementation TInfoController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Task", nil);

        UIImage * barImage = [[UIImage imageNamed:@"task_info_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        float imageOffset = 6;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImage];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        
        IQBadgeIndicatorView * badgeView = [[IQBadgeIndicatorView alloc] init];
        badgeView.badgeColor = [UIColor colorWithHexInt:0xe74545];
        badgeView.strokeBadgeColor = [UIColor whiteColor];
        badgeView.frame = CGRectMake(0, 0, 9.0f, 9.0f);
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(6.5f, 10.5f);
        
        ManagedTodoListModel * todoListModel = [[ManagedTodoListModel alloc] init];
        todoListModel.section = 1;
        self.model = todoListModel;

        [self resubscribeToIQNotifications];
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
    
    self.model.taskId = _task.taskId;
    
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}

- (void)setPolicyInspector:(TaskPolicyInspector *)policyInspector {
    _policyInspector = policyInspector;
    [self updateInterfaceFoPolicies];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [self markTaskAsReadedIfNeed];
    [self updateInterfaceFoPolicies];

    [self.model updateModelWithCompletion:^(NSError *error) {
        if (error == nil) {
            [self.tableView reloadData];
        }
    }];

    self.resetReadFlagAutomatically = YES;
    [self resetReadFlag];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 0 : [self.model numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TodoListItemCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    id<TodoItem> item = [self.model itemAtIndexPath:indexPath];
    cell.item = item;
    
    BOOL isCellChecked = [self.model isItemCheckedAtIndexPath:indexPath];
    [cell setAccessoryType:(isCellChecked) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
    
    cell.enabled = _changeStateEnabled;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = (section == 0) ? [TInfoHeaderView heightForTask:self.task width:self.tableView.frame.size.width descriptionExpanded:_descriptionExpanded] : 50.0f;
    return height;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [self mainHeaderView];
    }
    else {
        BOOL editEnabled = ([self.policyInspector isActionAvailable:@"update" inCategory:@"todoItems"]);
        TodoListSectionView * headerView = [[TodoListSectionView alloc] init];
        [headerView.editButton setHidden:!editEnabled];
        if (editEnabled) {
            [headerView.editButton addTarget:self
                                      action:@selector(editTodoItemsAction:)
                            forControlEvents:UIControlEventTouchUpInside];
        }
        return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isCellChecked = [self.model isItemCheckedAtIndexPath:indexPath];
    __weak typeof (self) weakSelf = self;
    void(^completion)(NSError *error) = ^(NSError *error) {
        [weakSelf proccessServiceError:error];
    };

    if (!isCellChecked) {
        [self.model completeTodoItemAtIndexPath:indexPath completion:completion];
    }
    else {
        [self.model rollbackTodoItemWithId:indexPath completion:completion];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Enable or disable change checked state
    if(_changeStateEnabled) {
        return ([self.model isItemSelectableAtIndexPath:indexPath]) ? indexPath : nil;
    }
    return nil;
}

#pragma mark - TInfoHeaderView Delegate

- (void)headerView:(TInfoHeaderView*)headerView tapActionAtIndex:(NSInteger)actionIndex actionButton:(UIButton*)actionButton {
    NSArray * actions = [self.task.availableActions array];
    NSString * action = (actionIndex < [actions count]) ? actions[actionIndex] : nil;
    [actionButton setEnabled:NO];
    
    if ([action length] > 0) {
        if([action isEqualToString:@"refuse"]) {
            _deferredActionButton = actionButton;
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:NSLocalizedString(@"Not in my competence", nil),
                                                                              NSLocalizedString(@"Incorrect task time", nil),
                                                                              NSLocalizedString(@"Not enough information", nil), nil];
            [actionSheet showInView:self.view];
        }
        else {
            [[IQService sharedService] changeStatus:action
                                      forTaskWithId:self.task.taskId
                                             reason:nil
                                            handler:^(BOOL success, IQTask * task, NSData *responseData, NSError *error) {
                                                if (success) {
                                                    self.task = task;
                                                    [self updateTaskPolicies];
                                                }
                                                else {
                                                    [self proccessServiceError:error];

                                                    [actionButton setEnabled:YES];
                                                }
                                            }];
        }
    }
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    static NSDictionary * reasons = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        reasons = @{
                                @(0) : @"not_in_my_competence",
                                @(1) : @"incorrect_task_time",
                                @(2) : @"not_enough_information"
                                };
    });
    
    NSString * reason = [reasons objectForKey:@(buttonIndex)];
    if(reason) {
        [[IQService sharedService] changeStatus:@"refuse"
                                  forTaskWithId:self.task.taskId
                                         reason:reason
                                        handler:^(BOOL success, IQTask * task, NSData *responseData, NSError *error) {
                                            if (success) {
                                                self.task = task;
                                                [self updateTaskPolicies];
                                            }
                                            else {
                                                [_deferredActionButton setEnabled:YES];
                                            }
                                        }];
    }
    else {
        [_deferredActionButton setEnabled:YES];
    }
    
    _deferredActionButton = nil;
}

#pragma mark - Private methods

- (void)editButtonAction:(UIButton*)sender {
    TaskModel * model = [[TaskModel alloc] init];
    model.task = [IQTaskDataHolder holderWithTask:self.task];
    
    TaskController * controller = [[TaskController alloc] init];
    controller.model = model;
    controller.hidesBottomBarWhenPushed = YES;
    [self.parentViewController.navigationController pushViewController:controller
                                                              animated:YES];
}

- (void)editTodoItemsAction:(UIButton*)sender {
    TodoListModel * model = [[TodoListModel alloc] initWithManagedItems:self.model.items];
    model.taskId = self.task.taskId;
    
    TTodoItemsController * controller = [[TTodoItemsController alloc] init];
    controller.model = model;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updateTask {
    [[IQService sharedService] taskWithId:self.task.taskId
                                  handler:^(BOOL success, IQTask * task, NSData *responseData, NSError *error) {
                                      if (success) {
                                          self.task = task;
                                          [self updateTaskPolicies];
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
                                            }
                                        }];
    }
}

- (void)applicationWillEnterForeground {
    if (self.resetReadFlagAutomatically) {
        [self resetReadFlag];
    }
    [self updateTask];
}

- (void)resubscribeToIQNotifications {
    [self unsubscribeFromIQNotifications];
    
    __weak typeof(self) weakSelf = self;
    void (^block)(IQCNotification * notf) = ^(IQCNotification * notf) {
        NSArray * tasks = notf.userInfo[IQNotificationDataKey];
        NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"task_id == %@", weakSelf.task.taskId];
        NSDictionary * curTask = [[tasks filteredArrayUsingPredicate:filterPredicate] lastObject];
        
        if(curTask) {
            [weakSelf updateTask];
            
            NSNumber * count = curTask[@"counter"];
            if(![weakSelf.badgeValue isEqualToNumber:count]) {
                if (weakSelf.resetReadFlagAutomatically) {
                    [weakSelf resetReadFlag];
                }
                else {
                    weakSelf.badgeValue = count;
                }
            }
        }
    };
    _notfObserver = [[IQNotificationCenter defaultCenter] addObserverForName:IQTaskDetailsUpdatedNotification
                                                                       queue:nil
                                                                  usingBlock:block];
}

- (void)unsubscribeFromIQNotifications {
    if(_notfObserver) {
        [[IQNotificationCenter defaultCenter] removeObserver:_notfObserver];
    }
}

- (void)resetReadFlag {
    [[IQService sharedService] markCategoryAsReaded:[self category]
                                             taskId:self.task.taskId
                                            handler:^(BOOL success, NSData *responseData, NSError *error) {
                                                if (success) {
                                                    self.tabBarItem.badgeValue = BadgTextFromInteger(0);
                                                }
                                            }];
}

- (UIView*)mainHeaderView {
    TInfoHeaderView * headerView = [[TInfoHeaderView alloc] init];
    headerView.descriptionView.expanded = _descriptionExpanded;
    [headerView.descriptionView setActionBlock:^(TInfoExpandableLineView *view) {
        if (view.enabled) {
            _descriptionExpanded = !_descriptionExpanded;
            [self.tableView reloadData];
        }
    }];
    [headerView setupByTask:self.task];
    headerView.delegate = self;
    return headerView;
}

- (NSString*)category {
    return @"details";
}

- (void)updateTaskPolicies {
    [self.policyInspector requestUserPoliciesWithCompletion:^(NSError *error) {
        if (error == nil) {
            [self updateInterfaceFoPolicies];
            
            if ([self isVisible]) {
                [self.tableView beginUpdates];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                              withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }
    }];
}

- (void)updateInterfaceFoPolicies {
    _changeStateEnabled = ([self.policyInspector isActionAvailable:@"change_state" inCategory:@"todoItems"]);

    if([self.policyInspector isActionAvailable:@"update" inCategory:[self category]]) {
        UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit_white_ico.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(editButtonAction:)];
        self.parentViewController.navigationItem.rightBarButtonItem = editButton;
    }
    else {
        self.parentViewController.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unsubscribeFromIQNotifications];
}

@end
