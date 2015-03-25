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
#import "IQTask.h"
#import "TaskCell.h"
#import "UIScrollView+PullToRefreshInsert.h"
#import "TasksFilterController.h"
#import "DispatchAfterExecution.h"
#import "TasksMenuCounters.h"
#import "IQSession.h"

#import "TaskTabController.h"
#import "TaskPolicyInspector.h"

@interface TasksController () <TasksFilterControllerDelegate> {
    TasksView * _mainView;
    TasksMenuModel * _menuModel;
    BOOL _isTaskOpenProcessing;
    UITapGestureRecognizer * _singleTapGesture;
}

@end

@implementation TasksController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Tasks", nil);
        UIImage * barImage = [[UIImage imageNamed:@"tasks_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage * barImageSel = [[UIImage imageNamed:@"tasks_tab_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
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
        badgeView.badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:9];
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(61.5f, 3.5f);
        
        self.model = [[TasksModel alloc] init];
        _menuModel = [[TasksMenuModel alloc] init];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    self.model.folder = [_menuModel folderForMenuItemAtIndexPath:indexPath];
    self.model.communityId = nil;
    self.model.statusFilter = nil;
    
    NSString * title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(DescriptionForSortField(self.model.sortField), nil), (self.model.ascending) ? @"↑" : @"↓"];
    _mainView.titleLabel.text = title;
    
    [self.model reloadModelWithCompletion:^(NSError *error) {
        if(!error) {
            [self.tableView reloadData];
            [self scrollToTopAnimated:NO delay:0.0f];
        }
    }];
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
    cell.item = task;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQTask * task = [self.model itemAtIndexPath:indexPath];

    TaskPolicyInspector * policyInspector = [[TaskPolicyInspector alloc] initWithTask:task];
    TaskTabController * controller = [[TaskTabController alloc] init];
    controller.task = task;
    controller.policyInspector = policyInspector;
    
    _isTaskOpenProcessing = YES;
    
    [policyInspector requestUserPoliciesWithCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"Failed request policies for taskId %@ with error:%@", task.taskId, error);
        }
        [self.navigationController pushViewController:controller animated:YES];
        _isTaskOpenProcessing = NO;
    }];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return (!_isTaskOpenProcessing) ? indexPath : nil;
}

#pragma mark - IQMenuModel Delegate

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

        NSMutableArray * fields = [NSMutableArray array];
        
        if([self.model.sortField length] > 0) {
            NSString * sort = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(DescriptionForSortField(self.model.sortField), nil),
                                                                   (self.model.ascending) ? @"↑" : @"↓"];
            [fields addObject:sort];
        }
        
        if([self.model.statusFilter length] > 0) {
            [fields addObject:NSLocalizedStringFromTable(self.model.statusFilter, @"FiltersLocalization", nil)];
        }
        
        if([controller.model.communityDescription length] > 0) {
            [fields addObject:controller.model.communityDescription];
        }
        
        _mainView.titleLabel.text = [fields componentsJoinedByString:@", "];
        
        [self.model reloadModelWithCompletion:^(NSError *error) {
            if(!error) {
                [self.tableView reloadData];
                [self scrollToTopAnimated:NO delay:0.0f];
            }
        }];
    }
}

#pragma mark -  Private methods

- (void)accountDidChanged {
    [self setupInitState];
}

- (void)setupInitState {
    [_menuModel selectItemAtIndexPath:[NSIndexPath indexPathForRow:0
                                                         inSection:0]];

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

- (void)updateNoDataLabelVisibility {
    [_mainView.noDataLabel setHidden:([self.model numberOfItemsInSection:0] > 0)];
}

- (void)updateBarBadgeWithValue:(NSInteger)badgeValue {
    BOOL hasUnreadNotf = (badgeValue > 0);
    NSString * badgeStringValue = (badgeValue > 99.0f) ? @"99+" : [NSString stringWithFormat:@"%ld", (long)badgeValue];
    self.tabBarItem.badgeValue = (hasUnreadNotf) ? badgeStringValue : nil;
}

@end
