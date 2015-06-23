//
//  ViewController.m
//  IQ300
//
//  Created by Tayphoon on 06.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "TasksController.h"
#import "UIViewController+LeftMenu.h"
#import "TasksView.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "IQBadgeView.h"
#import "TasksMenuModel.h"
#import "IQMenuItem.h"
#import "IQTask.h"
#import "TaskCell.h"
#import "UIScrollView+PullToRefreshInsert.h"
#import "TasksFilterController.h"
#import "DispatchAfterExecution.h"
#import "TasksMenuCounters.h"
#import "IQSession.h"

#import "TaskTabController.h"
#import "TaskPolicyInspector.h"
#import "TaskController.h"
#import "IQService+Tasks.h"

@interface TasksController () <TasksFilterControllerDelegate> {
    TasksView * _mainView;
    TasksMenuModel * _menuModel;
    BOOL _isTaskOpenProcessing;
    UITapGestureRecognizer * _singleTapGesture;
    BOOL _highlightTasks;
}

@end

@implementation TasksController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImage * barImage = [[UIImage imageNamed:@"tasks_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage * barImageSel = [[UIImage imageNamed:@"tasks_tab_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:barImage selectedImage:barImageSel];
        float imageOffset = 6;
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        
        IQBadgeStyle * style = [IQBadgeStyle defaultStyle];
        style.badgeTextColor = [UIColor whiteColor];
        style.badgeFrameColor = [UIColor whiteColor];
        style.badgeInsetColor = [UIColor colorWithHexInt:0xe74545];
        style.badgeFrame = YES;
        
        IQBadgeView * badgeView = [IQBadgeView customBadgeWithString:nil withStyle:style];
        badgeView.badgeMinSize = 20;
        badgeView.frameLineHeight = 1.0f;
        badgeView.badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:10];
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(5.5f, 5.5f);
        
        self.model = [[TasksModel alloc] init];
        _menuModel = [[TasksMenuModel alloc] init];
        _highlightTasks = YES;
    }
    return self;
}

- (void)loadView {
    _mainView = [[TasksView alloc] init];
    self.view = _mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupInitState];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf.model updateModelWithCompletion:^(NSError *error) {
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionTop];
    
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf.model loadNextPartWithCompletion:^(NSError *error) {
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionBottom] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionBottom];
    
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFilterController)];
    _singleTapGesture.numberOfTapsRequired = 1;

    [_mainView.headerView addGestureRecognizer:_singleTapGesture];
    [_mainView.filterButton addTarget:self
                               action:@selector(showFilterController)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accountDidChanged)
                                                 name:AccountDidChangedNotification
                                               object:nil];
    
    UIBarButtonItem * createTaskBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"white_add_ico.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(createTaskAction:)];
    self.navigationItem.rightBarButtonItem = createTaskBarButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 
    _isTaskOpenProcessing = NO;

    [self.leftMenuController setMenuResponder:self];
    [self.leftMenuController setTableHaderHidden:YES];
    [self.leftMenuController setModel:_menuModel];
    [self.leftMenuController reloadMenuWithCompletion:nil];
    
    if([IQSession defaultSession]) {
        [self.model updateModelWithCompletion:^(NSError *error) {
            if(!error) {
                [self.tableView reloadData];
            }
            
            [self updateNoDataLabelVisibility];
        }];
    }
    
    [self.model setSubscribedToNotifications:YES];
    [self updateControllerTitle];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.model setSubscribedToNotifications:NO];
}

- (UITableView*)tableView {
    return _mainView.tableView;
}

#pragma mark - Menu Responder Delegate

- (void)menuController:(MenuViewController*)controller didSelectMenuItemAtIndexPath:(NSIndexPath*)indexPath {
    [self updateControllerTitle];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    self.model.folder = [_menuModel folderForMenuItemAtIndexPath:indexPath];
    self.model.communityId = nil;
    self.model.statusFilter = [_menuModel statusForMenuItemAtIndexPath:indexPath];
    
    NSString * status = ([self.model.statusFilter length] > 0) ? [NSString stringWithFormat:@"_%@", self.model.statusFilter] : @"";
    NSString * label = [NSString stringWithFormat:@"%@%@", self.model.folder, status];
    [GAIService sendEventForCategory:GAITasksListEventCategory
                              action:@"event_action_tasks_list_menu"
                               label:label];
    
    [self updateSortFilterLabel];
    
    [self.model reloadModelWithCompletion:^(NSError *error) {
        if(!error) {
            [self.tableView reloadData];
            [self scrollToTopAnimated:NO delay:0.0f];
        }
    }];
    
    _highlightTasks = !([self.model.folder isEqualToString:@"archive"] ||
                        [self.model.folder isEqualToString:@"templates"]);
}

- (void)updateGlobalCounter {
    [self.model updateCountersWithCompletion:nil];
}

#pragma mark - UITableView DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQTask * task = [self.model itemAtIndexPath:indexPath];
    cell.highlightTasks = _highlightTasks;
    cell.item = task;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQTask * task = [self.model itemAtIndexPath:indexPath];

    TaskPolicyInspector * policyInspector = [[TaskPolicyInspector alloc] initWithTaskId:task.taskId];
    TaskTabController * controller = [[TaskTabController alloc] init];
    controller.task = task;
    controller.policyInspector = policyInspector;
    controller.hidesBottomBarWhenPushed = YES;
    
    _isTaskOpenProcessing = YES;
    
    [policyInspector requestUserPoliciesWithCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"Failed request policies for taskId %@ with error:%@", task.taskId, error);
        }

        [GAIService sendEventForCategory:GAITasksListEventCategory
                                  action:GAIOpenTaskEventAction];

        [self.navigationController pushViewController:controller animated:YES];
        _isTaskOpenProcessing = NO;
    }];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return (!_isTaskOpenProcessing) ? indexPath : nil;
}

#pragma mark - IQTableModel Delegate

- (void)modelCountersDidChanged:(id<IQTableModel>)model {
    _menuModel.counters = self.model.counters;
    [self updateBarBadgeWithValue:[self.model.counters.total integerValue]];
}

#pragma mark - IQMenuModel Delegate

- (void)filterControllerWillFinish:(TasksFilterController *)controller {
    TasksFilterModel * model = controller.model;
    if (![self.model.sortField isEqualToString:model.sortField] ||
        self.model.ascending != model.ascending ||
        (model.communityId && ![self.model.communityId isEqualToNumber:model.communityId]) ||
        (!model.communityId && self.model.communityId) ||
        ![self.model.statusFilter isEqualToString:model.statusFilter]) {
     
        self.model.sortField = model.sortField;
        self.model.statusFilter = model.statusFilter;
        self.model.ascending = model.ascending;
        self.model.communityId = model.communityId;
        self.model.communityDescription = controller.model.communityDescription;
        
        NSIndexPath * menuIndexPath = [_menuModel indexPathForItemWithStatus:self.model.statusFilter
                                                                      folder:self.model.folder];
        if (menuIndexPath) {
            [_menuModel selectItemAtIndexPath:menuIndexPath];
        }
        else {
            menuIndexPath = [_menuModel indexPathForItemWithFolder:self.model.folder];
            [_menuModel selectItemAtIndexPath:menuIndexPath];
        }

        [self updateSortFilterLabel];

        [self.model reloadModelWithCompletion:^(NSError *error) {
            if(!error) {
                [self.tableView reloadData];
                [self scrollToTopAnimated:NO delay:0.0f];
            }
        }];
    }
}

#pragma mark -  Private methods

- (void)updateSortFilterLabel {
    NSMutableArray * fields = [NSMutableArray array];
    
    if([self.model.sortField length] > 0) {
        NSString * sort = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(DescriptionForSortField(self.model.sortField), nil),
                           (self.model.ascending) ? @"↑" : @"↓"];
        [fields addObject:sort];
    }
    
    if([self.model.statusFilter length] > 0) {
        [fields addObject:NSLocalizedStringFromTable(self.model.statusFilter, @"FiltersLocalization", nil)];
    }
    
    if([self.model.communityDescription length] > 0) {
        [fields addObject:self.model.communityDescription];
    }
    
    _mainView.titleLabel.text = [fields componentsJoinedByString:@", "];
}

- (void)accountDidChanged {
    [self setupInitState];
}

- (void)setupInitState {
    self.model.communityId = nil;
    self.model.statusFilter = nil;
    self.model.folder = [_menuModel folderForMenuItemAtIndexPath:[_menuModel indexPathForSelectedItem]];
    
    NSString * title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(DescriptionForSortField(self.model.sortField), nil), (self.model.ascending) ? @"↑" : @"↓"];
    _mainView.titleLabel.text = title;
}

- (void)showFilterController {
    TasksFilterModel * model = [[TasksFilterModel alloc] init];
    model.folder = self.model.folder;
    model.sortField = self.model.sortField;
    model.statusFilter = self.model.statusFilter;
    model.ascending = self.model.ascending;
    model.communityId = self.model.communityId;

    TasksFilterController * controller = [[TasksFilterController alloc] init];
    controller.title = NSLocalizedString(@"Filtering and sorting", nil);
    controller.model = model;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)createTaskAction:(UIButton*)sender {
    if (!_isTaskOpenProcessing) {
        _isTaskOpenProcessing = YES;
        [[IQService sharedService] mostUsedCommunityWithHandler:^(BOOL success, id community, NSData *responseData, NSError *error) {
            if (success) {
                TaskModel * model = [[TaskModel alloc] init];
                model.defaultCommunity = community;
                
                TaskController * controller = [[TaskController alloc] init];
                controller.model = model;
                controller.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:controller
                                                     animated:YES];
            }
        }];
    }
}

- (void)updateNoDataLabelVisibility {
    [_mainView.noDataLabel setHidden:([self.model numberOfItemsInSection:0] > 0)];
}

- (void)updateBarBadgeWithValue:(NSInteger)badgeValue {
    self.tabBarItem.badgeValue = BadgTextFromInteger(badgeValue);
}

- (void)updateControllerTitle {
    NSIndexPath * indexPath = [_menuModel indexPathForSelectedItem];
    IQMenuItem * menuItem = [_menuModel itemAtIndexPath:indexPath];
    NSString * title = menuItem.title;
    if (indexPath.row == 3 || indexPath.row == 4) {
        title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Inbox", nil), menuItem.title];
    }
    else if (indexPath.row == 6 || indexPath.row == 7) {
        title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Outbox", nil), menuItem.title];
    }
    
    self.navigationItem.title = title;
}

@end
