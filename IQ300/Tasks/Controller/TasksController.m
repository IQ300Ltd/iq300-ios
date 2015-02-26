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

@interface TasksController () {
    TasksView * _mainView;
    TasksMenuModel * _menuModel;
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
    
    [_menuModel selectItemAtIndexPath:[NSIndexPath indexPathForRow:0
                                                         inSection:0]];
    self.model.folder = [_menuModel folderForMenuItemAtIndexPath:[_menuModel indexPathForSelectedItem]];
    
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFilterController)];
    _singleTapGesture.numberOfTapsRequired = 1;

    [_mainView.headerView addGestureRecognizer:_singleTapGesture];
    [_mainView.filterButton addTarget:self
                               action:@selector(showFilterController)
                     forControlEvents:UIControlEventTouchUpInside];
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
    [self.model updateModelWithCompletion:nil];
}

- (UITableView*)tableView {
    return _mainView.tableView;
}

#pragma mark - Menu Responder Delegate

- (void)menuController:(MenuViewController*)controller didSelectMenuItemAtIndexPath:(NSIndexPath*)indexPath {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    self.model.folder = [_menuModel folderForMenuItemAtIndexPath:indexPath];
    [self.model reloadModelWithCompletion:^(NSError *error) {
        if(!error) {
            [self.tableView reloadData];
        }
    }];
}

- (void)updateGlobalCounter {
    
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
}

#pragma mark -  Private methods

- (void)showFilterController {
    TasksFilterModel * model = [[TasksFilterModel alloc] init];

    TasksFilterController * controller = [[TasksFilterController alloc] init];
    controller.title = NSLocalizedString(@"Filtering and sorting", nil);
    controller.model = model;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
