//
//  NotificationsContoller.m
//  IQ300
//
//  Created by Tayphoon on 11.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <SVPullToRefresh/UIScrollView+SVPullToRefresh.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "NotificationsContoller.h"
#import "NotificationsView.h"
#import "NotificationsMenuModel.h"
#import "UIViewController+LeftMenu.h"
#import "NotificationsModel.h"
#import "IQNotification.h"
#import "NotificationCell.h"

//#import "UITableView+BottomRefreshControl.h"
//#import "IQRefreshControl.h"

@interface NotificationsContoller() <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate> {
    NotificationsView * _mainView;
    NotificationsMenuModel * _menuModel;
}

@end

@implementation NotificationsContoller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        UIImage * barImage = [[UIImage imageNamed:@"notif_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage * barImageSel = [[UIImage imageNamed:@"notif_tab_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Notifications", nil) image:barImage selectedImage:barImageSel];
        self.model = [[NotificationsModel alloc] init];
    }
    
    return self;
}

- (void)loadView {
    _mainView = [[NotificationsView alloc] init];
    self.view = _mainView;
}

- (UITableView*)tableView {
    return _mainView.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
        
    _menuModel = [[NotificationsMenuModel alloc] init];
    [_menuModel selectItemAtIndexPath:[NSIndexPath indexPathForRow:(self.model.loadUnreadOnly) ? 1 : 0
                                                         inSection:0]];
    
//    IQRefreshControl *bottomRefreshControl = [IQRefreshControl new];
//    [bottomRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
//    self.tableView.bottomRefreshControl = bottomRefreshControl;
    
    __weak typeof(self) weakSelf = self;
    [self.tableView
     addPullToRefreshWithActionHandler:^{
         [weakSelf.model updateModelWithCompletion:nil];
         [weakSelf.tableView.pullToRefreshView stopAnimating];
     }
     position:SVPullToRefreshPositionBottom];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accountDidChanged)
                                                 name:AccountDidChangedNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mark_tab_item.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self action:@selector(markAllAsReaded:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    [self.leftMenuController setMenuResponder:self];
    [self.leftMenuController setTableHaderHidden:YES];
    [self.leftMenuController setModel:_menuModel];
    [self.leftMenuController reloadMenuWithCompletion:nil];
    
    [self updateCounters];
    [self reloadDataWithCompletion:nil];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQNotification * notification = [self.model itemAtIndexPath:indexPath];
    cell.item = notification;
    cell.markAsReadedButton.tag = indexPath.row;
    cell.delegate = self;
    cell.tag = indexPath.row;
        
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 105;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    IQNotification * notification = [self.model itemAtIndexPath:indexPath];
}

#pragma mark - Menu Responder Delegate

- (void)menuController:(MenuViewController*)controller didSelectMenuItemAtIndexPath:(NSIndexPath*)indexPath {
    self.model.loadUnreadOnly = (indexPath.row == 1);
    [self reloadModel];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - Private methods

- (void)markAllAsReaded:(id)sender {
    [self.model markAllNotificationAsReadWithCompletion:^(NSError *error) {
        if(!error) {
            [self updateCounters];
            [_mainView.noDataLabel setHidden:YES];
        }
    }];
}

- (void)swipeableTableViewCell:(NotificationCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath * itemIndexPath = [self.model indexPathOfObject:cell.item];
    
    [self.model markNotificationAsReadAtIndexPath:itemIndexPath completion:^(NSError *error) {
        if(!error) {
            [self updateCounters];
            [_mainView.noDataLabel setHidden:YES];
        }
    }];
}

- (void)updateCounters {
    [self.model updateCountersWithCompletion:^(NSError *error) {
        if(!error) {
            _menuModel.totalItemsCount = self.model.totalItemsCount;
            _menuModel.unreadItemsCount = self.model.unreadItemsCount;
        }
    }];
}

- (void)accountDidChanged {
    [self reloadModel];
}

- (void)reloadModel {
    [self.model reloadModelWithCompletion:^(NSError *error) {
        if(!error) {
            [self.tableView reloadData];
            if([self.model numberOfItemsInSection:0] > 0) {
                [_mainView.noDataLabel setHidden:YES];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionTop
                                              animated:NO];
            }
            else {
                [_mainView.noDataLabel setHidden:NO];
                [self.model updateModelWithCompletion:^(NSError *error) {
                    if([self.model numberOfItemsInSection:0] > 0) {
                        [_mainView.noDataLabel setHidden:YES];
                    }
                }];
            }
            [self updateCounters];
        }
    }];
}

@end
