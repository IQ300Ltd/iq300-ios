//
//  MessagesController.m
//  IQ300
//
//  Created by Tayphoon on 02.12.14.
//  Copyright (c) 2014 Tayphoon. All rights reserved.
//
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "UIViewController+LeftMenu.h"
#import "IQSession.h"

#import "MessagesController.h"
#import "MessagesView.h"
#import "ConversationCell.h"
#import "IQConversation.h"

#import "DiscussionController.h"
#import "CreateConversationController.h"
#import "DispatchAfterExecution.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "IQBadgeView.h"
#import "IQCounters.h"
#import "UIScrollView+PullToRefreshInsert.h"
#import "IQDrawerController.h"

#define DISPATCH_DELAY 0.7

@interface MessagesController() {
    MessagesView * _messagesView;
    dispatch_after_block _cancelBlock;
}

@end

@implementation MessagesController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.model = [[MessagesModel alloc] init];
        self.title = NSLocalizedString(@"Messages", nil);
        
        self.needFullReload = YES;

        UIImage * barImage = [[UIImage imageNamed:@"messages_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage * barImageSel = [[UIImage imageNamed:@"messgaes_tab_sel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        float imageOffset = 6;
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:barImage selectedImage:barImageSel];
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(imageOffset, 0, -imageOffset, 0);
        
        IQBadgeStyle * style = [IQBadgeStyle defaultStyle];
        style.badgeTextColor = [UIColor whiteColor];
        style.badgeFrameColor = [UIColor whiteColor];
        style.badgeInsetColor = [UIColor colorWithHexInt:0xe74545];
        style.badgeFrame = YES;
        
        IQBadgeView * badgeView = [IQBadgeView customBadgeWithString:nil withStyle:style];
        badgeView.badgeMinSize = 18;
        badgeView.frameLineHeight = 1.0f;
        badgeView.badgeTextFont = [UIFont fontWithName:IQ_HELVETICA size:9];
        
        self.tabBarItem.customBadgeView = badgeView;
        self.tabBarItem.badgeOrigin = CGPointMake(61.5f, 3.5f);
    }
    return self;
}

- (void)loadView {
    _messagesView = [[MessagesView alloc] init];
    self.view = _messagesView;
}

- (UITableView*)tableView {
    return _messagesView.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [_messagesView.searchBar addTarget:self
                                action:@selector(textFieldDidChange:)
                      forControlEvents:UIControlEventEditingChanged];

    _messagesView.searchBar.delegate = (id<UITextFieldDelegate>)self;
    
    __weak typeof(self) weakSelf = self;
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf.model reloadFirstPartWithCompletion:^(NSError *error) {
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionTop];
    
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf.model updateModelWithCompletion:^(NSError *error) {
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
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"createNewMessage.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self action:@selector(createNewAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;

    
    [self.leftMenuController setModel:nil];
    [self.leftMenuController reloadMenuWithCompletion:nil];
    
    if([IQSession defaultSession]) {
        [self reloadModel];
    }
    
    [self.model setSubscribedToNotifications:YES];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(drawerDidShowNotification:)
                                                 name:IQDrawerDidShowNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.model setSubscribedToNotifications:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IQDrawerDidShowNotification
                                                  object:nil];
}

- (void)updateGlobalCounter {
    __weak typeof(self) weakSelf = self;
    [self.model updateCountersWithCompletion:^(IQCounters *counter, NSError *error) {
        [weakSelf updateBarBadgeWithValue:[counter.unreadCount integerValue]];
    }];
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConversationCell * cell = [tableView dequeueReusableCellWithIdentifier:[self.model reuseIdentifierForIndexPath:indexPath]];
    
    if (!cell) {
        cell = [self.model createCellForIndexPath:indexPath];
    }
    
    IQConversation * conversation = [self.model itemAtIndexPath:indexPath];
    cell.item = conversation;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ConversationCell * cell = (ConversationCell*)[tableView cellForRowAtIndexPath:indexPath];
    IQConversation * conver = [self.model itemAtIndexPath:indexPath];
    DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:conver.discussion];
    model.companionId = cell.companion.userId;

    DiscussionController * controller = [[DiscussionController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.title = cell.companion.displayName;
    controller.model = model;

    [self.navigationController pushViewController:controller animated:YES];
    
    __weak typeof(self) weakSelf = self;
    [MessagesModel markConversationAsRead:conver completion:^(NSError *error) {
        [weakSelf updateGlobalCounter];
    }];
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
    [self updateBarBadgeWithValue:self.model.unreadItemsCount];
}

#pragma mark - Menu Responder Delegate

- (void)menuController:(MenuViewController*)controller didSelectMenuItemAtIndexPath:(NSIndexPath*)indexPath {
    self.model.loadUnreadOnly = (indexPath.row == 1);
    [self reloadModel];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TextField Delegate

- (void)textFieldDidChange:(UITextField *)textField {
    [self filterWithText:textField.text];
}

#pragma mark - Keyboard Helpers

- (void)onKeyboardWillShow:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:NO notification:notification];
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:YES notification:notification];
}

#pragma mark - Private methods

- (void)makeInputViewTransitionWithDownDirection:(BOOL)down notification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    [_messagesView setTableBottomMargin:down ? 0.0f : MIN(keyboardRect.size.width, keyboardRect.size.height) - 50.0f];
    
    [UIView commitAnimations];
}

- (void)createNewAction:(id)sender {
    CreateConversationController * controller = [[CreateConversationController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.model = [[UsersModel alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)reloadModel {
    [self.model reloadModelWithCompletion:^(NSError *error) {
        if(!error) {
            [self.tableView reloadData];
        }
        [self updateNoDataLabelVisibility];
        [self scrollToTopIfNeedAnimated:NO delay:0.0f];
        self.needFullReload = NO;
   }];
}

- (void)updateNoDataLabelVisibility {
    [_messagesView.noDataLabel setHidden:([self.model numberOfItemsInSection:0] > 0)];
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

- (void)filterWithText:(NSString *)text {
    if(_cancelBlock) {
        cancel_dispatch_after_block(_cancelBlock);
    }
    
    void(^compleationBlock)(NSError * error) = ^(NSError * error) {
        if(!error) {
            [self.tableView reloadData];
            [self updateNoDataLabelVisibility];
        }
    };
    
    [self.model setFilter:text];
    [self.model updateModelSourceControllerWithCompletion:compleationBlock];
    
    _cancelBlock = dispatch_after_delay(DISPATCH_DELAY, dispatch_get_main_queue(), ^{
        [self.model reloadFirstPartWithCompletion:compleationBlock];
    });
}

- (void)updateBarBadgeWithValue:(NSInteger)badgeValue {
    BOOL hasUnreadNotf = (badgeValue > 0);
    NSString * badgeStringValue = (badgeValue > 99.0f) ? @"99+" : [NSString stringWithFormat:@"%ld", (long)badgeValue];
    self.tabBarItem.badgeValue = (hasUnreadNotf) ? badgeStringValue : nil;
}

- (void)countersDidChangedNotification:(NSNotification*)notification {
    NSString * counterName = [notification.userInfo[ChangedCounterNameUserInfoKey] lowercaseString];
    if([counterName isEqualToString:@"messages"]) {
        [self updateGlobalCounter];
    }
}

- (void)drawerDidShowNotification:(NSNotification*)notification {
    [_messagesView.searchBar resignFirstResponder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CountersDidChangedNotification
                                                  object:nil];
}

@end
