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

#import "SharingMessagesController.h"
#import "MessagesView.h"
#import "ConversationCell.h"
#import "IQConversation.h"

#import "SharingDiscussionController.h"
#import "ContactPickerController.h"
#import "DispatchAfterExecution.h"
#import "UITabBarItem+CustomBadgeView.h"
#import "IQBadgeView.h"
#import "IQCounters.h"
#import "IQContact.h"
#import "UIScrollView+PullToRefreshInsert.h"
#import "IQDrawerController.h"

#import "SharingViewController.h"

#define DISPATCH_DELAY 0.7

@interface SharingMessagesController() <IQSelectionControllerDelegate> {
    MessagesView * _messagesView;
    dispatch_after_block _cancelBlock;
    SharingAttachment *_attachement;
}

@end

@implementation SharingMessagesController

@dynamic model;

- (instancetype)initWithAttachment:(SharingAttachment *)attachment {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.model = [[MessagesModel alloc] init];
        self.title = NSLocalizedString(@"Messages", nil);
        self.needFullReload = YES;
        _attachement = attachment;
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
    
    [_messagesView.clearTextFieldButton addTarget:self
                                           action:@selector(clearSearch)
                                 forControlEvents:UIControlEventTouchUpInside];
    
    __weak typeof(self) weakSelf = self;
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf.model updateModelWithCompletion:^(NSError *error) {
             [self proccessServiceError:error];
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionTop] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionTop];
    
    [self.tableView
     insertPullToRefreshWithActionHandler:^{
         [weakSelf.model loadNextPartWithCompletion:^(NSError *error) {
             [self proccessServiceError:error];
             [[weakSelf.tableView pullToRefreshForPosition:SVPullToRefreshPositionBottom] stopAnimating];
         }];
     }
     position:SVPullToRefreshPositionBottom];
    
    UIBarButtonItem * rightBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"createNewMessage.png"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(createNewAction:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.model.modelUpdateRequired = YES;
    [self updateModel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    self.model.modelUpdateRequired = NO;
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
    IQConversation * conversation = [self.model itemAtIndexPath:indexPath];
    DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:conversation.discussion];

    SharingDiscussionController * controller = [[SharingDiscussionController alloc] initWithAttachment:_attachement];
    controller.title = conversation.title;
    controller.model = model;
    controller.sharingController = self.sharingController;
    
    [self.navigationController pushViewController:controller animated:YES];
    
    [MessagesModel markConversationAsRead:conversation completion:nil];
}

#pragma mark - Menu Responder Delegate

- (void)menuController:(MenuViewController*)controller didSelectMenuItemAtIndexPath:(NSIndexPath*)indexPath {
    self.model.loadUnreadOnly = (indexPath.row == 1);
    [self reloadModel];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _messagesView.clearTextFieldButton.hidden = (textField.text.length == 0);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    [self filterWithText:textField.text];
    _messagesView.clearTextFieldButton.hidden = (textField.text.length == 0);
}

#pragma mark - Keyboard Helpers

- (void)onKeyboardWillShow:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:NO notification:notification];
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    [self makeInputViewTransitionWithDownDirection:YES notification:notification];
}

#pragma mark - Activity indicator overrides

- (void)showActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self.tableView setPullToRefreshAtPosition:SVPullToRefreshPositionTop shown:NO];
    [self.tableView setPullToRefreshAtPosition:SVPullToRefreshPositionBottom shown:NO];
    
    [super showActivityIndicatorAnimated:YES completion:nil];
}

- (void)hideActivityIndicatorAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [super hideActivityIndicatorAnimated:YES completion:^{
        [self.tableView setPullToRefreshAtPosition:SVPullToRefreshPositionTop shown:YES];
        [self.tableView setPullToRefreshAtPosition:SVPullToRefreshPositionBottom shown:YES];
        
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - ContactPickerController delegate

- (void)contactPickerController:(ContactPickerController*)picker didPickContacts:(NSArray*)contacts {
    if ([contacts count] == 1) {
        IQContact * contact = [contacts firstObject];
        [self createDiscussionWithUserId:contact.user.userId];
    }
    else if ([contacts count] > 1) {
        NSArray * users = [contacts valueForKey:@"user"];
        NSArray * userIds = [users valueForKey:@"userId"];
        [self createConferenceWithUserIds:userIds];
    }
}

#pragma mark - Private methods

- (void)createDiscussionWithUserId:(NSNumber*)userId {
    [MessagesModel createConversationWithRecipientId:userId
                                          completion:^(IQConversation * conversation, NSError *error) {
                                              if(!error) {
                                                  DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:conversation.discussion];
                                                  
                                                  SharingDiscussionController * controller = [[SharingDiscussionController alloc] initWithAttachment:_attachement];
                                                  
                                                  controller.hidesBottomBarWhenPushed = YES;
                                                  controller.model = model;
                                                  controller.title = conversation.title;
                                                  controller.sharingController = self.sharingController;
                                                  
                                                  [MessagesModel markConversationAsRead:conversation completion:nil];
                                                  
                                                  NSArray * newStack = @[self, controller];
                                                  [self.navigationController setViewControllers:newStack animated:YES];
                                              }
                                              else {
                                                  [self proccessServiceError:error];
                                              }
                                          }];
}

- (void)createConferenceWithUserIds:(NSArray*)userIds {
    [MessagesModel createConferenceWithUserIds:userIds
                                    completion:^(IQConversation * conversation, NSError *error) {
                                        if(!error) {
                                            DiscussionModel * model = [[DiscussionModel alloc] initWithDiscussion:conversation.discussion];
                                            
                                            SharingDiscussionController * controller = [[SharingDiscussionController alloc] initWithAttachment:_attachement];
                                            controller.hidesBottomBarWhenPushed = YES;
                                            controller.model = model;
                                            controller.title = conversation.title;
                                            controller.sharingController = self.sharingController;

                                            [MessagesModel markConversationAsRead:conversation completion:nil];
                                            
                                            NSArray * newStack = @[self, controller];
                                            [self.navigationController setViewControllers:newStack animated:YES];
                                        }
                                        else {
                                            [self proccessServiceError:error];
                                        }
                                    }];
}

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
    
    CGFloat inset = MIN(keyboardRect.size.height, keyboardRect.size.width);
    if (!IS_IPAD) {
        inset -= self.tabBarController.tabBar.frame.size.height;
    }
    [_messagesView setTableBottomMargin:down ? 0.0f : inset];
    
    [UIView commitAnimations];
}

- (void)createNewAction:(id)sender {
    ContactPickerController * controller = [[ContactPickerController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    controller.model = [[ContactsModel alloc] init];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)cancelAction:(id)sender {
    NSAssert(_sharingController, @"Sharing controller not exists");
    [_sharingController finishActivity:NO];
}

- (void)reloadModel {
    if([IQSession defaultSession]) {
        [self showActivityIndicatorAnimated:YES completion:nil];

        [self.model reloadModelWithCompletion:^(NSError *error) {
            if(!error) {
                [self.tableView reloadData];
            }
            [self updateNoDataLabelVisibility];
            [self scrollToTopIfNeedAnimated:NO delay:0.0f];
            self.needFullReload = NO;
            
            dispatch_after_delay(0.5, dispatch_get_main_queue(), ^{
                [self hideActivityIndicatorAnimated:YES completion:nil];
            });
        }];
    }
}

- (void)updateModel {
    if([IQSession defaultSession]) {
        [self showActivityIndicatorAnimated:YES completion:nil];
        
        [self.model updateModelWithCompletion:^(NSError *error) {
            [self.tableView reloadData];
            [self updateNoDataLabelVisibility];
            [self scrollToTopIfNeedAnimated:NO delay:0.0f];
            self.needFullReload = NO;
            
            dispatch_after_delay(0.5, dispatch_get_main_queue(), ^{
                [self hideActivityIndicatorAnimated:YES completion:nil];
            });
        }];
    }
}

- (void)applicationWillEnterForeground {
    [self updateModel];
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

- (void)filterWithText:(NSString *)text {
    if(_cancelBlock) {
        cancel_dispatch_after_block(_cancelBlock);
    }
    
    void(^compleationBlock)(NSError * error) = ^(NSError * error) {
        [self.tableView reloadData];
        [self updateNoDataLabelVisibility];
        [self proccessServiceError:error];
    };
    
    [self.model setFilter:text];
    
    _cancelBlock = dispatch_after_delay(DISPATCH_DELAY, dispatch_get_main_queue(), ^{
        [self.model reloadModelWithCompletion:compleationBlock];
    });
}

- (void)drawerDidShowNotification:(NSNotification*)notification {
    [_messagesView.searchBar resignFirstResponder];
}

- (void)clearSearch {
    _messagesView.clearTextFieldButton.hidden = YES;
    _messagesView.searchBar.text = nil;
    [self filterWithText:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
