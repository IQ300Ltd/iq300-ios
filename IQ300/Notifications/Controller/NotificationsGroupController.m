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
#import "NotificationsGroupModel.h"
#import "IQNotificationsGroup.h"
#import "IQNotification.h"
#import "IQCounters.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "IQBadgeView.h"
#import "IQService+Messages.h"
#import "DispatchAfterExecution.h"
#import "UIScrollView+PullToRefreshInsert.h"
#import "NotificationsController.h"
#import "IQDiscussion.h"
#import "CommentsController.h"
#import "TaskTabController.h"
#import "IQService+Feedback.h"
#import "FeedbackController.h"

@interface NotificationsGroupController () <SWTableViewCellDelegate> {
    NotificationsView * _mainView;
    NotificationsMenuModel * _menuModel;
}

@end

@implementation NotificationsGroupController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.needFullReload = YES;
        
        self.model = [[NotificationsGroupModel alloc] init];
        
        _menuModel = [[NotificationsMenuModel alloc] init];
        
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
        badgeView.badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:10];
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(5.5f, 5.5f);
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
    
    _mainView.noDataLabel.text = NSLocalizedString((self.model.loadUnreadOnly) ? NoUnreadNotificationFound : NoNotificationFound, nil);
    
    [_menuModel selectItemAtIndexPath:[NSIndexPath indexPathForRow:(self.model.loadUnreadOnly) ? 1 : 0
                                                         inSection:0]];

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
    [self.model updateCountersWithCompletion:^(IQCounters *counter, NSError *error) {
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
    
    cell.showUnreadOnly = self.model.loadUnreadOnly;
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
    IQNotification * notification = (self.model.loadUnreadOnly) ? group.lastUnreadNotification : group.lastNotification;
    BOOL hasOneUnread = ([group.unreadCount integerValue] == 1);
    
    if ((hasOneUnread && self.model.loadUnreadOnly) || [group.totalCount integerValue] == 1) {
        if ([notification.notificable.type isEqualToString:@"BaseTask"]) {
            [self openTaskControllerForNotification:notification
                                        atIndexPath:(hasOneUnread) ? indexPath : nil];
        }
        else if([notification.notificable.type isEqualToString:@"ErrorReport"]) {
            [self openFeedbackControllerForNotification:notification
                                            atIndexPath:(hasOneUnread) ? indexPath : nil];
        }
        else if(notification.discussionId) {
            [self openCommentsControllerForNotification:notification
                                            atIndexPath:(hasOneUnread) ? indexPath : nil];
        }
    }
    else {
        NotificationsModel * model = [[NotificationsModel alloc] init];
        model.loadUnreadOnly = self.model.loadUnreadOnly;
        model.group = group;
        
        NotificationsController * controller = [[NotificationsController alloc] init];
        controller.title = NSLocalizedString(notification.notificable.type, nil);
        controller.model = model;
        controller.hidesBottomBarWhenPushed = YES;

        if ([notification.readed boolValue]) {
            [GAIService sendEventForCategory:GAINotificationsEventCategory
                                      action:GAIOpenReadedNotificationEventAction];
        }

        [self.navigationController pushViewController:controller animated:YES];
    }
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

- (void)modelCountersDidChanged:(id<IQTableModel>)model {
    _menuModel.totalItemsCount = self.model.totalItemsCount;
    _menuModel.unreadItemsCount = self.model.unreadItemsCount;
    [self updateBarBadgeWithValue:self.model.unreadItemsCount];
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
            [weakSelf proccessServiceError:error];
        }
    };
    
    NSIndexPath * itemIndexPath = [self.model indexPathOfObject:cell.item];
    if(![cell.item.lastNotification.hasActions boolValue]) {
        UIAlertViewCompletionBlock alertBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(buttonIndex == 1) {
                [weakSelf.model markNotificationsAsReadAtIndexPath:itemIndexPath completion:completion];
            }
        };
        
        if([cell.item.unreadCount integerValue] > 1) {
        [UIAlertView showWithTitle:@"IQ300" message:NSLocalizedString(@"mark_all_group_readed_question", nil)
                 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                 otherButtonTitles:@[NSLocalizedString(@"OK", nil)]
                          tapBlock:alertBlock];
        }
        else {
            alertBlock(nil, 1);
        }
    }
    else {
        if(index == 0) {
            [self.model acceptNotificationsGroupAtIndexPath:itemIndexPath completion:completion];
        }
        else {
            [self.model declineNotificationsGroupAtIndexPath:itemIndexPath completion:completion];
        }
    }
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

- (void)reloadModel {
    [self.model reloadModelWithCompletion:^(NSError *error) {
        [self.tableView reloadData];
        [self scrollToTopAnimated:NO delay:0.5];
        [self updateNoDataLabelVisibility];
        self.needFullReload = NO;
    }];
}

- (void)reloadFirstPart {
    [self.model reloadFirstPartWithCompletion:^(NSError *error) {
        [self.tableView reloadData];
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

- (void)updateNoDataLabelVisibility {
    [_mainView.noDataLabel setHidden:([self.model numberOfItemsInSection:0] > 0)];
}

- (void)updateBarBadgeWithValue:(NSInteger)badgeValue {
    self.tabBarItem.badgeValue = BadgTextFromInteger(badgeValue);
}

- (void)countersDidChangedNotification:(NSNotification*)notification {
    NSString * counterName = [notification.userInfo[ChangedCounterNameUserInfoKey] lowercaseString];
    if([counterName isEqualToString:@"notifications"]) {
        [self updateGlobalCounter];
    }
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
                                                   
                                                   if(indexPath) {
                                                       [self.model markNotificationsAsReadAtIndexPath:indexPath completion:nil];
                                                   }
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
                                              
                                              if(indexPath) {
                                                  [self.model markNotificationsAsReadAtIndexPath:indexPath completion:nil];
                                              }
                                          }
                                          else {
                                              [self proccessServiceError:error];
                                          }
                                      }];
}

- (void)openCommentsControllerForNotification:(IQNotification*)notification atIndexPath:(NSIndexPath*)indexPath {
    NSString * title = notification.notificable.title;
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
                                                
                                                if(indexPath) {
                                                    [self.model markNotificationsAsReadAtIndexPath:indexPath completion:nil];
                                                }
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
}

@end
