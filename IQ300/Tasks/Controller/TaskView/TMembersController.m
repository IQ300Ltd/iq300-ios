//
//  TMembersController.m
//  IQ300
//
//  Created by Tayphoon on 17.03.15.
//  Copyright (c) 2015 Tayphoon. All rights reserved.
//
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/CALayer.h>

#import "TMembersController.h"
#import "ContactPickerController.h"
#import "IQSession.h"
#import "TMemberCell.h"
#import "IQUser.h"
#import "IQTaskMember.h"
#import "IQTask.h"
#import "DiscussionController.h"
#import "MessagesModel.h"
#import "IQConversation.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "UIScrollView+PullToRefreshInsert.h"
#import "TaskPolicyInspector.h"
#import "TaskNotifications.h"
#import "IQBadgeIndicatorView.h"

@interface TMembersController () <ContactPickerControllerDelegate, SWTableViewCellDelegate> {
}

@end

@implementation TMembersController

@dynamic model;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Members", nil);

        UIImage * barImage = [[UIImage imageNamed:@"task_member_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        float imageOffset = 6;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImage];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        
        IQBadgeIndicatorView * badgeView = [[IQBadgeIndicatorView alloc] init];
        badgeView.badgeColor = [UIColor colorWithHexInt:0xe74545];
        badgeView.frame = CGRectMake(0, 0, 5.0f, 5.0f);
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(5.5f, 3.5f);

        self.model = [[TaskMembersModel alloc] init];
    }
    return self;
}

- (void)setBadgeValue:(NSNumber *)badgeValue {
    self.tabBarItem.badgeValue = BadgTextFromInteger([badgeValue integerValue]);
}

- (NSNumber*)badgeValue {
    return @([self.tabBarItem.badgeValue integerValue]);
}

- (void)setTaskId:(NSNumber *)taskId {
    if(![_taskId isEqualToNumber:taskId]) {
        _taskId = taskId;
        
        self.model.taskId = taskId;
        
        if(self.isViewLoaded) {
            [self reloadModel];
        }
    }
}

- (void)setPolicyInspector:(TaskPolicyInspector *)policyInspector {
    _policyInspector = policyInspector;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf reloadDataWithCompletion:^(NSError *error) {
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionTop];
    
    [self.noDataLabel setText:NSLocalizedString(@"No contacts", nil)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskPolicyDidChanged:)
                                                 name:IQTaskPolicyDidChangedNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateInterfaceFoPolicies];
    [self reloadModel];
    
    self.model.resetReadFlagAutomatically = YES;
    [self.model setSubscribedToNotifications:YES];
    [self.model resetReadFlagWithCompletion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.model.resetReadFlagAutomatically = NO;
    [self.model setSubscribedToNotifications:NO];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMemberCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    
    IQTaskMember * member = [self.model itemAtIndexPath:indexPath];
    cell.item = member;
    cell.delegate = self;
    cell.availableActions = [self.policyInspector availableActionsForMember:member
                                                                   category:self.model.category];
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IQTaskMember * member = [self.model itemAtIndexPath:indexPath];
    NSString * companionName = member.user.displayName;
    NSNumber * userId = member.user.userId;
    [MessagesModel createConversationWithRecipientId:userId
                                          completion:^(IQConversation * conv, NSError *error) {
                                              if(!error) {
                                                  DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:conv.discussion];
                                                  model.companionId = userId;
                                                  
                                                  DiscussionController * controller = [[DiscussionController alloc] init];
                                                  controller.hidesBottomBarWhenPushed = YES;
                                                  controller.model = model;
                                                  controller.title = companionName;
                                                  
                                                  [MessagesModel markConversationAsRead:conv completion:nil];
                                                  [self.navigationController pushViewController:controller animated:YES];
                                              }
                                          }];
}

#pragma mark - SWTableViewCell Delegate

- (void)swipeableTableViewCell:(TMemberCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    IQTaskMember * member = [self.model itemAtIndexPath:indexPath];

    if ([member.user.userId isEqualToNumber:[IQSession defaultSession].userId]) {
        [self.model leaveTaskWithMemberId:member.memberId completion:^(NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:IQTasksDidLeavedNotification
                                                                    object:self
                                                                  userInfo:@{ @"taskId" : self.model.taskId }];
            }
            else {
                [self showErrorAlertWithMessage:NSLocalizedString(@"You can not leave the task", nil)];
            }
        }];
    }
    else {
        [self.model removeMemberWithId:member.memberId completion:^(NSError *error) {
            if (error) {
                [self showErrorAlertWithMessage:NSLocalizedString(@"You can not remove the user from the task", nil)];
            }
        }];
    }
}

#pragma mark - ContactPickerController Delegate

- (void)contactPickerController:(ContactPickerController *)picker didPickUser:(IQUser *)user {
    [self.model addMemberWithUserId:user.userId completion:^(NSError *error) {
        
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IQTableModel Delegate

- (void)modelCountersDidChanged:(TaskMembersModel*)model {
    self.badgeValue = self.model.unreadCount;
}

#pragma mark - Private methods

- (void)showErrorAlertWithMessage:(NSString*)errorMessage {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"IQ300"
                                                      message:errorMessage
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                            otherButtonTitles:nil];
    [message show];
}

- (void)addButtonAction:(UIButton*)sender {
    NSArray * users = [self.model.members valueForKey:@"user"];
    
    ContactPickerController * controller = [[ContactPickerController alloc] init];
    controller.model = [[UsersModel alloc] init];
    controller.model.excludeUserIds = [users valueForKey:@"userId"];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)reloadModel {
    if([IQSession defaultSession]) {
        [self reloadDataWithCompletion:^(NSError *error) {
            [self updateNoDataLabelVisibility];
        }];
    }
}

#pragma mark - Policies methods

- (void)taskPolicyDidChanged:(NSNotification*)notification {
    if (notification.object == _policyInspector && [self isVisible]) {
        [self updateInterfaceFoPolicies];
        [self.tableView reloadData];
    }
}

- (void)updateInterfaceFoPolicies {
    if([self.policyInspector isActionAvailable:@"create" inCategory:self.model.category]) {
        UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"white_add_ico.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(addButtonAction:)];
        self.parentViewController.navigationItem.rightBarButtonItem = addButton;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
