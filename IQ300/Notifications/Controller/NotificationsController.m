//
//  NotificationsContoller.m
//  IQ300
//
//  Created by Tayphoon on 11.11.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "UIViewController+LeftMenu.h"
#import "IQSession.h"

#import "NotificationsController.h"
#import "NotificationGroupView.h"
#import "NotificationsMenuModel.h"
#import "NotificationsModel.h"
#import "IQNotification.h"
#import "NotificationCell.h"
#import "IQCounters.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "IQBadgeView.h"
#import "IQService+Messages.h"
#import "IQDiscussion.h"
#import "CommentsController.h"
#import "DispatchAfterExecution.h"
#import "UIScrollView+PullToRefreshInsert.h"
#import "IQNotificationsGroup.h"
#import "TaskTabController.h"
#import "IQService+Feedback.h"
#import "FeedbackController.h"

@interface NotificationsController() <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate> {
    NotificationGroupView * _mainView;
    NotificationsMenuModel * _menuModel;
}

@end

@implementation NotificationsController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.needFullReload = YES;

        self.title = NSLocalizedString(@"Notifications", nil);
    }
    
    return self;
}

- (void)loadView {
    _mainView = [[NotificationGroupView alloc] init];
    self.view = _mainView;
}

- (UITableView*)tableView {
    return _mainView.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mainView.noDataLabel.text = NSLocalizedString((self.model.loadUnreadOnly) ? NoUnreadNotificationFound : NoNotificationFound, nil);
    
    _menuModel = [[NotificationsMenuModel alloc] init];
    [_menuModel selectItemAtIndexPath:[NSIndexPath indexPathForRow:(self.model.loadUnreadOnly) ? 1 : 0
                                                         inSection:0]];
    
    [_mainView.backButton addTarget:self
                             action:@selector(backButtonAction:)
                   forControlEvents:UIControlEventTouchUpInside];
    
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
    
    IQNotification * notification = self.model.group.lastNotification;
    if([notification.notificable.title length] > 0) {
        _mainView.titleLabel.text = self.model.group.lastNotification.notificable.title;
    }
    else {
#ifdef IPAD
        [_mainView setHeaderViewHidden:YES];
#else
        _mainView.titleLabel.text = NSLocalizedString(notification.notificable.type, nil);
#endif
    }
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
        [self updateModel];
    }
    
    [self.model setSubscribedToNotifications:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.model setSubscribedToNotifications:NO];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQNotification * notification = [self.model itemAtIndexPath:indexPath];
    cell.item = notification;
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model.cellWidth = tableView.frame.size.width;
    return [self.model heightForItemAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQNotification * notification = [self.model itemAtIndexPath:indexPath];
    if ([notification.notificable.type isEqualToString:@"BaseTask"]) {
        [self openTaskControllerForNotification:notification atIndexPath:indexPath];
    }
    else if([notification.notificable.type isEqualToString:@"ErrorReport"]) {
        [self openFeedbackControllerForNotification:notification
                                        atIndexPath:indexPath];
    }
    else if(notification.discussionId) {
        [self openCommentsControllerForNotification:notification atIndexPath:indexPath];
    }
}

#pragma mark - IQTableModel Delegate

- (void)modelCountersDidChanged:(id<IQTableModel>)model {
    _menuModel.totalItemsCount = self.model.totalItemsCount;
    _menuModel.unreadItemsCount = self.model.unreadItemsCount;
}

#pragma mark - Menu Responder Delegate

- (void)menuController:(MenuViewController*)controller didSelectMenuItemAtIndexPath:(NSIndexPath*)indexPath {
    self.model.loadUnreadOnly = (indexPath.row == 1);
    _mainView.noDataLabel.text = NSLocalizedString((indexPath.row == 0) ? NoNotificationFound : NoUnreadNotificationFound, nil);
    [self reloadModel];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - SWTableViewCell Delegate

- (void)swipeableTableViewCell:(NotificationCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    __weak typeof (self) weakSelf = self;
    void(^completion)(NSError *error) = ^(NSError *error) {
        if (!error) {
            if([weakSelf.model numberOfItemsInSection:0] == 0) {
                [weakSelf.model updateModelWithCompletion:^(NSError *error) {
                    [weakSelf updateNoDataLabelVisibility];
                }];
            }
        }
        else {
            [self proccessServiceError:error];
        }
    };
    
    if(![cell.item.hasActions boolValue]) {
        NSIndexPath * itemIndexPath = [self.model indexPathOfObject:cell.item];
        
        [self.model markNotificationAsReadAtIndexPath:itemIndexPath completion:completion];
    }
    else {
        if(index == 0) {
            [self.model acceptNotification:cell.item completion:completion];
        }
        else {
            [self.model declineNotification:cell.item completion:completion];
        }
    }
}

#pragma mark - Private methods

- (void)backButtonAction:(UIButton*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)markAllAsReaded:(id)sender {
    if(![IQService sharedService].isServiceReachable) {
        [self showHudWindowWithText:NSLocalizedString(INTERNET_UNREACHABLE_MESSAGE, nil)];
    }
    else {
        if(self.model.unreadItemsCount > 0) {
            [UIAlertView showWithTitle:@"IQ300" message:NSLocalizedString(@"mark_all_readed_question", nil)
                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                     otherButtonTitles:@[NSLocalizedString(@"OK", nil)]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if(buttonIndex == 1) {
                                      [self.model markAllNotificationAsReadWithCompletion:^(NSError *error) {
                                          [self proccessServiceError:error];
                                      }];
                                  }
                              }];
        }
        else {
            [UIAlertView showWithTitle:@"IQ300" message:NSLocalizedString(NoUnreadNotificationFound, nil)
                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                     otherButtonTitles:nil
                              tapBlock:nil];
        }
    }
}

- (void)reloadModel {
    [self.model reloadModelWithCompletion:^(NSError *error) {
        if(!error) {
            [self.tableView reloadData];
        }
        [self scrollToTopAnimated:NO delay:0.5];
        [self updateNoDataLabelVisibility];
    }];
}

- (void)updateModel {
    [self.model updateModelWithCompletion:^(NSError *error) {
        if (!error) {
            [self.tableView reloadData];
        }
        
        [self scrollToTopIfNeedAnimated:NO delay:0.5];
        [self updateNoDataLabelVisibility];
        self.needFullReload = NO;
    }];
}

- (void)scrollToTopIfNeedAnimated:(BOOL)animated delay:(CGFloat)delay {
    CGFloat topPosition = 0.0f;
    BOOL isTableScrolledToBottom = (self.tableView.contentOffset.y <= topPosition);
    if(isTableScrolledToBottom || self.needFullReload) {
        [self scrollToTopAnimated:animated delay:delay];
    }
}

- (void)updateNoDataLabelVisibility {
    [_mainView.noDataLabel setHidden:([self.model numberOfItemsInSection:0] > 0)];
}

- (void)openTaskControllerForNotification:(IQNotification*)notification atIndexPath:(NSIndexPath*)indexPath {
    //Enable pop to root only for unread mode
    NSString * groupSid = self.model.loadUnreadOnly ? notification.groupSid : nil;
    BOOL isDiscussionNotification = (notification.discussionId != nil);
    
    [TaskTabController taskTabControllerForTaskWithId:notification.notificable.notificableId
                                           completion:^(TaskTabController * controller, NSError *error) {
                                               if (controller) {
                                                   [GAIService sendEventForCategory:GAITasksListEventCategory
                                                                             action:GAIOpenTaskEventAction];
                                                   
                                                   [GAIService sendEventForCategory:GAINotificationsEventCategory
                                                                             action:GAIOpenNotificationEventAction
                                                                              label:notification.notificable.type];

                                                   if ([notification.readed boolValue]) {
                                                       [GAIService sendEventForCategory:GAINotificationsEventCategory
                                                                                 action:GAIOpenReadedNotificationEventAction];
                                                   }

                                                   controller.selectedIndex = (isDiscussionNotification) ? 1 : 0;
                                                   controller.notificationsGroupSid = groupSid;
                                                   controller.hidesBottomBarWhenPushed = YES;
                                                   [self.navigationController pushViewController:controller animated:YES];
                                                   
                                                   [self.model markNotificationAsReadAtIndexPath:indexPath completion:nil];
                                               }
                                               else {
                                                   [self proccessServiceError:error];
                                               }
                                           }];
}

- (void)openFeedbackControllerForNotification:(IQNotification*)notification atIndexPath:(NSIndexPath*)indexPath {
    [[IQService sharedService] feedbackWithId:notification.notificable.notificableId
                                      handler:^(BOOL success, IQManagedFeedback * feedback, NSData *responseData, NSError *error) {
                                          if (success) {
                                              FeedbackController * controller = [[FeedbackController alloc] init];
                                              controller.feedback = feedback;
                                              controller.hidesBottomBarWhenPushed = YES;
                                              [self.navigationController pushViewController:controller animated:YES];
                                              
                                              [self.model markNotificationAsReadAtIndexPath:indexPath completion:nil];
                                          }
                                          else {
                                              [self proccessServiceError:error];
                                          }
                                      }];
}

- (void)openCommentsControllerForNotification:(IQNotification*)notification atIndexPath:(NSIndexPath*)indexPath {
    NSString * title = ([notification.notificable.title length] > 0) ? notification.notificable.title :
                                                                       NSLocalizedString(notification.notificable.type, nil);
    NSNumber * commentId = notification.commentId;
    [[IQService sharedService] discussionWithId:notification.discussionId
                                        handler:^(BOOL success, IQDiscussion * discussion, NSData *responseData, NSError *error) {
                                            if(success) {
                                                [GAIService sendEventForCategory:GAINotificationsEventCategory
                                                                          action:GAIOpenNotificationEventAction
                                                                           label:notification.notificable.type];

                                                if ([notification.readed boolValue]) {
                                                    [GAIService sendEventForCategory:GAINotificationsEventCategory
                                                                              action:GAIOpenReadedNotificationEventAction];
                                                }

                                                CommentsModel * model = [[CommentsModel alloc] initWithDiscussion:discussion];
                                                CommentsController * controller = [[CommentsController alloc] init];
                                                controller.model = model;
                                                controller.title = title;
                                                controller.highlightedCommentId = commentId;
                                                controller.hidesBottomBarWhenPushed = YES;

                                                [self.navigationController pushViewController:controller animated:YES];
                                                
                                                [self.model markNotificationAsReadAtIndexPath:indexPath completion:nil];
                                            }
                                            else {
                                                [self proccessServiceError:error];
                                            }
                                        }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CountersDidChangedNotification
                                                  object:nil];
    [self.model setSubscribedToNotifications:NO];
    [self.leftMenuController setMenuResponder:nil];
    [self.leftMenuController setModel:nil];
}

@end
