//
//  NotificationsGroupController.m
//  IQ300
//
//  Created by Tayphoon on 28.01.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "UIViewController+LeftMenu.h"
#import "IQSession.h"

#import "NotificationsGroupController.h"
#import "NotificationsView.h"
#import "NotificationsMenuModel.h"
#import "NGroupCell.h"
#import "NGroupModel.h"
#import "IQNotificationsGroup.h"
#import "IQNotification.h"
#import "IQCounters.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "IQBadgeView.h"
#import "IQService+Messages.h"
#import "DispatchAfterExecution.h"
#import "UIScrollView+PullToRefreshInsert.h"
#import "NotificationsController.h"

@interface NotificationsGroupController () <SWTableViewCellDelegate> {
    NotificationsView * _mainView;
    NotificationsMenuModel * _menuModel;
}

@end

@implementation NotificationsGroupController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.needFullReload = YES;
        
        self.model = [[NGroupModel alloc] init];
        
        self.title = NSLocalizedString(@"Notifications", nil);
        UIImage * barImage = [[UIImage imageNamed:@"notif_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage * barImageSel = [[UIImage imageNamed:@"notif_tab_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
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
    _mainView.noDataLabel.text = NSLocalizedString((self.model.loadUnreadOnly) ? NoUnreadNotificationFound : NoNotificationFound, nil);
    
    _menuModel = [[NotificationsMenuModel alloc] init];
    [_menuModel selectItemAtIndexPath:[NSIndexPath indexPathForRow:(self.model.loadUnreadOnly) ? 1 : 0
                                                         inSection:0]];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(countersDidChangedNotification:)
                                                 name:CountersDidChangedNotification
                                               object:nil];
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
        [self reloadFirstPart];
    }
    
    [self.model setSubscribedToNotifications:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.model setSubscribedToNotifications:NO];
}

- (void)updateGlobalCounter {
    __weak typeof(self) weakSelf = self;
    [self.model updateGlobalCountersWithCompletion:^(IQCounters *counter, NSError *error) {
        [weakSelf updateBarBadgeWithValue:[counter.unreadCount integerValue]];
    }];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NGroupCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQNotificationsGroup * group = [self.model itemAtIndexPath:indexPath];
    cell.item = group;
    cell.markAsReadedButton.tag = indexPath.row;
    cell.delegate = self;
    cell.tag = indexPath.row;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQNotificationsGroup * group = [self.model itemAtIndexPath:indexPath];
    NotificationsModel * model = [[NotificationsModel alloc] init];
    model.loadUnreadOnly = self.model.loadUnreadOnly;
    model.group = group;
    
    NotificationsController * controller = [[NotificationsController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.title = NSLocalizedString(group.lastNotification.notificable.type, nil);
    controller.model = model;
    
    [self.navigationController pushViewController:controller animated:YES];
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

#pragma mark - SWTableViewCell Delegate

- (void)swipeableTableViewCell:(NGroupCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath * itemIndexPath = [self.model indexPathOfObject:cell.item];
    [UIAlertView showWithTitle:@"IQ300" message:NSLocalizedString(@"mark_all_group_readed_question", nil)
             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
             otherButtonTitles:@[NSLocalizedString(@"OK", nil)]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if(buttonIndex == 1) {
                              [self markGroupAsReadedAtIndexPath:itemIndexPath];
                          }
                      }];

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

- (void)markGroupAsReadedAtIndexPath:(NSIndexPath*)itemIndexPath {
    __weak typeof (self) weakSelf = self;
    void(^completion)(NSError *error) = ^(NSError *error) {
        if([weakSelf.model numberOfItemsInSection:0] == 0) {
            [weakSelf.model updateModelWithCompletion:^(NSError *error) {
                [weakSelf updateNoDataLabelVisibility];
            }];
        }
    };
    
    [self.model markNotificationsAsReadAtIndexPath:itemIndexPath completion:completion];
}

- (void)reloadModel {
    [self.model reloadModelWithCompletion:^(NSError *error) {
        if(!error) {
            [self.tableView reloadData];
        }
        [self scrollToTopIfNeedAnimated:NO delay:0.5];
        [self updateNoDataLabelVisibility];
        self.needFullReload = NO;
    }];
}

- (void)reloadFirstPart {
    [self.model reloadFirstPartWithCompletion:^(NSError *error) {
        if(!error) {
            [self.tableView reloadData];
        }
        
        [self scrollToTopIfNeedAnimated:NO delay:0.5];
        [self updateNoDataLabelVisibility];
        self.needFullReload = NO;
    }];
}

- (void)scrollToTopIfNeedAnimated:(BOOL)animated delay:(CGFloat)delay {
    CGFloat bottomPosition = 0.0f;
    BOOL isTableScrolledToBottom = (self.tableView.contentOffset.y <= bottomPosition);
    if(isTableScrolledToBottom || self.needFullReload) {
        [self scrollToTopAnimated:animated delay:delay];
    }
}

- (void)scrollToTopAnimated:(BOOL)animated delay:(CGFloat)delay {
    NSInteger section = [self.tableView numberOfSections];
    if (section > 0) {
        NSInteger itemsCount = [self.tableView numberOfRowsInSection:0];
        
        if (itemsCount > 0) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            if(delay > 0.0f) {
                dispatch_after_delay(delay, dispatch_get_main_queue(), ^{
                    [self scrollToTopAnimated:animated delay:0.0f];
                });
            }
            else {
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
            }
        }
    }
}

- (void)updateNoDataLabelVisibility {
    [_mainView.noDataLabel setHidden:([self.model numberOfItemsInSection:0] > 0)];
}

- (void)modelCountersDidChanged:(id<IQTableModel>)model {
    _menuModel.totalItemsCount = self.model.totalItemsCount;
    _menuModel.unreadItemsCount = self.model.unreadItemsCount;
}

- (void)updateBarBadgeWithValue:(NSInteger)badgeValue {
    BOOL hasUnreadNotf = (badgeValue > 0);
    NSString * badgeStringValue = (badgeValue > 99.0f) ? @"99+" : [NSString stringWithFormat:@"%ld", (long)badgeValue];
    self.tabBarItem.badgeValue = (hasUnreadNotf) ? badgeStringValue : nil;
}

- (void)countersDidChangedNotification:(NSNotification*)notification {
    NSString * counterName = [notification.userInfo[ChangedCounterNameUserInfoKey] lowercaseString];
    if([counterName isEqualToString:@"notifications"]) {
        [self updateGlobalCounter];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CountersDidChangedNotification
                                                  object:nil];
}

@end