//
//  NotificationsContoller.m
//  IQ300
//
//  Created by Tayphoon on 11.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <SVPullToRefresh/UIScrollView+SVPullToRefresh.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "UIViewController+LeftMenu.h"
#import "IQSession.h"

#import "NotificationsContoller.h"
#import "NotificationsView.h"
#import "NotificationsMenuModel.h"
#import "NotificationsModel.h"
#import "IQNotification.h"
#import "NotificationCell.h"
#import "IQCounters.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "IQBadgeView.h"

@interface NotificationsContoller() <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate> {
    NotificationsView * _mainView;
    NotificationsMenuModel * _menuModel;
}

@end

@implementation NotificationsContoller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.model = [[NotificationsModel alloc] init];

        self.title = NSLocalizedString(@"Notifications", nil);
        UIImage * barImage = [[UIImage imageNamed:@"notif_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage * barImageSel = [[UIImage imageNamed:@"notif_tab_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:barImage selectedImage:barImageSel];
        float imageOffset = 6;
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        
        BadgeStyle * style = [BadgeStyle defaultStyle];
        style.badgeTextColor = [UIColor whiteColor];
        style.badgeFrameColor = [UIColor whiteColor];
        style.badgeInsetColor = [UIColor colorWithHexInt:0xe74545];
        style.badgeFrame = YES;
        
        IQBadgeView * badgeView = [IQBadgeView customBadgeWithString:nil withStyle:style];
        badgeView.badgeMinSize = 18;
        badgeView.frameLineHeight = 1.0f;
        badgeView.badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:9];
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(88, 7);
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
    
    __weak typeof(self) weakSelf = self;
    [self.tableView
     addPullToRefreshWithActionHandler:^{
         [weakSelf.model updateModelWithCompletion:^(NSError *error) {
             [weakSelf.tableView.pullToRefreshView stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionBottom];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mark_tab_item.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(markAllAsReaded:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    [self.leftMenuController setMenuResponder:self];
    [self.leftMenuController setTableHaderHidden:YES];
    [self.leftMenuController setModel:_menuModel];
    [self.leftMenuController reloadMenuWithCompletion:nil];
    
    if([IQSession defaultSession]) {
        [self reloadModel];
    }
    
    [self.model setSubscribedToNotifications:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.model setSubscribedToNotifications:NO];
}

- (void)updateGlobalCounter {
    __weak typeof(self) weakSelf = self;
    [self.model updateCountersWithCompletion:^(IQCounters *counter, NSError *error) {
        [weakSelf updateBarBadgeWithValue:[counter.unreadCount integerValue]];
    }];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - IQTableModel Delegate

- (void)modelDidChangeContent:(id<IQTableModel>)model {
    [super modelDidChangeContent:model];
    [self updateNoDataLabelVisibility];
}

- (void)modelDidChanged:(id<IQTableModel>)model {
    [super modelDidChanged:model];
    [self updateNoDataLabelVisibility];
}

#pragma mark - Menu Responder Delegate

- (void)menuController:(MenuViewController*)controller didSelectMenuItemAtIndexPath:(NSIndexPath*)indexPath {
    self.model.loadUnreadOnly = (indexPath.row == 1);
    _mainView.noDataLabel.text = NSLocalizedString((indexPath.row == 0) ? NoNotificationFound : NoUnreadNotificationFound, nil);
    [self reloadModel];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - Private methods

- (void)markAllAsReaded:(id)sender {
    if(self.model.unreadItemsCount > 0) {
        [UIAlertView showWithTitle:@"IQ300" message:NSLocalizedString(@"mark_all_readed_question", nil)
                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                 otherButtonTitles:@[NSLocalizedString(@"OK", nil)]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if(buttonIndex == 1) {
                                  [self.model markAllNotificationAsReadWithCompletion:^(NSError *error) {
                                  }];
                              }
                          }];
    }
    else {
        [UIAlertView showWithTitle:@"IQ300" message:NSLocalizedString(NoUnreadNotificationFound, nil)
                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                 otherButtonTitles:nil
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              
                          }];
    }
}

- (void)swipeableTableViewCell:(NotificationCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath * itemIndexPath = [self.model indexPathOfObject:cell.item];
    
    [self.model markNotificationAsReadAtIndexPath:itemIndexPath completion:^(NSError *error) {
        if([self.model numberOfItemsInSection:0] == 0) {
            [self.model updateModelWithCompletion:^(NSError *error) {
                [self updateNoDataLabelVisibility];
            }];
        }
    }];
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
                    [self updateNoDataLabelVisibility];
                }];
            }
        }
    }];
}

- (void)updateNoDataLabelVisibility {
    [_mainView.noDataLabel setHidden:([self.model numberOfItemsInSection:0] > 0)];
}

- (void)modelCountersDidChanged:(id<IQTableModel>)model {
    _menuModel.totalItemsCount = self.model.totalItemsCount;
    _menuModel.unreadItemsCount = self.model.unreadItemsCount;
    [self updateBarBadgeWithValue:self.model.unreadItemsCount];
}

- (void)updateBarBadgeWithValue:(NSInteger)badgeValue {
    BOOL hasUnreadNotf = (badgeValue > 0);
    NSString * badgeStringValue = (badgeValue > 99.0f) ? @"99+" : [NSString stringWithFormat:@"%d", badgeValue];
    self.tabBarItem.badgeValue = (hasUnreadNotf) ? badgeStringValue : nil;
}

@end
