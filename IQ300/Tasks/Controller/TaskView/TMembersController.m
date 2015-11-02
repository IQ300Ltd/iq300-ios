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
#import "DispatchAfterExecution.h"
#import "IQContact.h"

@interface TMembersController () <IQSelectionControllerDelegate, SWTableViewCellDelegate>

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
        badgeView.strokeBadgeColor = [UIColor whiteColor];
        badgeView.frame = CGRectMake(0, 0, 9.0f, 9.0f);
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(6.0f, 10.5f);

        self.model = [[TaskMembersModel alloc] init];
    }
    return self;
}

- (void)setBadgeValue:(NSNumber *)badgeValue {
    if(!self.model.resetReadFlagAutomatically) {
        self.tabBarItem.badgeValue = BadgTextFromInteger([badgeValue integerValue]);
    }
}

- (NSNumber*)badgeValue {
    return @([self.tabBarItem.badgeValue integerValue]);
}

- (void)setTaskId:(NSNumber *)taskId {
    if(![_taskId isEqualToNumber:taskId]) {
        _taskId = taskId;
        
        self.model.taskId = taskId;
        
        if(self.isViewLoaded) {
            [self updateModel];
        }
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [self updateInterfaceFoPolicies];
    
    self.model.resetReadFlagAutomatically = YES;
    [self.model resetReadFlagWithCompletion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateModel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    self.model.resetReadFlagAutomatically = NO;
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
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    IQTaskMember * member = [self.model itemAtIndexPath:indexPath];
    if ([member.user.userId isEqualToNumber:[IQSession defaultSession].userId]) {
        [self showErrorAlertWithMessage:NSLocalizedString(@"You can not write a message to yourself", nil)];
        return;
    }
    
    NSNumber * userId = member.user.userId;
    [MessagesModel createConversationWithRecipientId:userId
                                          completion:^(IQConversation * conversation, NSError *error) {
                                              if(!error) {
                                                  DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:conversation.discussion];
                                                  
                                                  DiscussionController * controller = [[DiscussionController alloc] init];
                                                  controller.hidesBottomBarWhenPushed = YES;
                                                  controller.model = model;
                                                  controller.title = conversation.title;
                                                  
                                                  [MessagesModel markConversationAsRead:conversation completion:nil];
                                                  [self.navigationController pushViewController:controller animated:YES];
                                              }
                                              else {
                                                  [self proccessServiceError:error];
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
                [self proccessServiceError:error];
            }
        }];
    }
    else {
        [self.model removeMemberWithId:member.memberId completion:^(NSError *error) {
            [self proccessServiceError:error];
        }];
    }
}

#pragma mark - ContactPickerController Delegate

- (void)selectionControllerController:(ContactPickerController *)controller didSelectItem:(IQContact*)item {
    [self.navigationController popViewControllerAnimated:YES];
    
    __weak typeof (self) weakSelf = self;
    [self.model addMemberWithUserId:item.user.userId completion:^(NSError *error) {
        if (!error) {
            [GAIService sendEventForCategory:GAITaskEventCategory
                                      action:@"event_action_task_add_user"];
        }
        else {
            [weakSelf proccessServiceError:error];
        }
    }];
}

#pragma mark - IQTableModel Delegate

- (void)modelCountersDidChanged:(TaskMembersModel*)model {
    self.tabBarItem.badgeValue = BadgTextFromInteger([self.model.unreadCount integerValue]);
}

#pragma mark - Activity indicator overrides

- (void)showActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self.tableView setPullToRefreshAtPosition:SVPullToRefreshPositionTop shown:NO];
    
    [super showActivityIndicatorAnimated:YES completion:nil];
}

- (void)hideActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [super hideActivityIndicatorAnimated:YES completion:^{
        [self.tableView setPullToRefreshAtPosition:SVPullToRefreshPositionTop shown:YES];
        
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Private methods

- (void)addButtonAction:(UIButton*)sender {
    NSArray * users = [self.model.members valueForKey:@"user"];
    
    ContactsModel * model = [[ContactsModel alloc] init];
    model.allowsDeselection = NO;
    model.allowsMultipleSelection = NO;
    model.excludeUserIds = [users valueForKey:@"userId"];

    ContactPickerController * controller = [[ContactPickerController alloc] init];
    controller.model = model;
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)updateModel {
    if([IQSession defaultSession]) {
        [self showActivityIndicatorAnimated:YES completion:nil];

        [self.model updateModelWithCompletion:^(NSError *error) {
            if(!error) {
                [self.tableView reloadData];
            }
            
            [self updateNoDataLabelVisibility];
            dispatch_after_delay(0.5f, dispatch_get_main_queue(), ^{
                [self hideActivityIndicatorAnimated:YES completion:nil];
            });
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
    else {
        self.parentViewController.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)applicationWillEnterForeground {
    if([IQSession defaultSession]) {
        [self showActivityIndicatorAnimated:YES completion:nil];
        
        [self.model updateModelWithCompletion:^(NSError *error) {
            [self updateNoDataLabelVisibility];
            
            dispatch_after_delay(0.5f, dispatch_get_main_queue(), ^{
                [self hideActivityIndicatorAnimated:YES completion:nil];
            });
        }];
        
        if (self.model.resetReadFlagAutomatically) {
            [self.model resetReadFlagWithCompletion:nil];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
